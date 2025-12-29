import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/draft_vendor_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
import '../../blocs/draft/draft_bloc.dart';
import '../../blocs/draft/draft_event.dart';
import '../../blocs/draft/draft_state.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../../blocs/vendor_form/vendor_form_event.dart';
import '../../blocs/vendor_form/vendor_form_state.dart';
import '../../blocs/vendor_stepper/vendor_stepper_bloc.dart';
import '../../blocs/vendor_stepper/vendor_stepper_event.dart';
import '../../blocs/vendor_stepper/vendor_stepper_state.dart';
import '../../widgets/custom_button.dart';
import 'sections/banking_details_section.dart';
import 'sections/business_details_section.dart';
import 'sections/documents_section.dart';
import 'sections/personal_details_section.dart';
import 'sections/photos_section.dart';
import 'sections/signature_section.dart';
import 'utils/draft_helper.dart';
import 'widgets/animated_section_container.dart';
import 'widgets/section_header.dart';
import 'widgets/stepper_navigation_buttons.dart';
import 'widgets/vendor_otp_dialog.dart';

class VendorProfileScreen extends StatefulWidget {
  final UserEntity user;
  final String? draftId;
  final VendorEntity? vendorDetails;
  final bool isEditMode;

  const VendorProfileScreen({
    super.key,
    required this.user,
    this.draftId,
    this.vendorDetails,
    this.isEditMode = false,
  });

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());
  List<bool>? _previousExpandedState;
  int? _previousCurrentSection;
  String? _currentDraftId;
  bool _isSavingDraft = false;

  // Controllers - Personal Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _residentialAddressController = TextEditingController();
  File? _aadhaarFrontImage;
  File? _aadhaarBackImage;

  // Controllers - Business Details
  final _businessNameController = TextEditingController();
  final _businessLegalNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessMobileController = TextEditingController();
  final _altBusinessMobileController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Controllers - Banking Details
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();

  // Controllers - Documents
  final _panCardNumberController = TextEditingController();
  final _gstCertificateNumberController = TextEditingController();
  final _businessRegistrationNumberController = TextEditingController();
  final _professionalLicenseNumberController = TextEditingController();
  final _additionalDocumentNameController = TextEditingController();

  // Signature
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  final _signerNameController = TextEditingController();
  Uint8List? _signatureBytes;

  // Categories
  List<String> _selectedBusinessCategories = [];
  List<CategoryModel> _availableCategories = [];
  Map<String, String> _categoryNameToId = {};
  bool _categoriesLoaded = false;

  // Files
  File? _businessRegistrationFile;
  File? _gstCertificateFile;
  File? _panCardFile;
  File? _professionalLicenseFile;
  File? _additionalDocumentFile;
  String? _businessRegistrationFileName;
  String? _gstCertificateFileName;
  String? _panCardFileName;
  String? _professionalLicenseFileName;
  String? _additionalDocumentFileName;

  // Images
  List<File> _frontStoreImages = [];

  // Terms
  bool _acceptedTerms = false;

  // OTP verification state
  bool _isOtpVerificationInProgress = false;
  String? _verifiedOtp; // Store verified OTP
  String?
  _mobileNumberForOtp; // Store mobile number used for OTP (must match in vendor creation)
  final ApiService _apiService = ApiService();

  // Section data
  final List<_SectionData> _sections = [
    _SectionData('Authorized Personal Details', Icons.person_outline),
    _SectionData('Business Details', Icons.business_outlined),
    _SectionData('Banking Details', Icons.account_balance_outlined),
    _SectionData('Documents & Certifications', Icons.description_outlined),
    _SectionData('Photos', Icons.photo_library_outlined),
    _SectionData('Digital Signature', Icons.draw_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _currentDraftId =
        widget.draftId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _fetchCategories();

    // If we are in edit mode with vendor details, prefill the form
    if (widget.isEditMode && widget.vendorDetails != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillVendorDetails(widget.vendorDetails!);
      });
    }
    // Otherwise, if we are resuming an existing draft, load and restore its data
    else if (widget.draftId != null) {
      _loadDraft(widget.draftId!);
    }
  }

  Future<void> _loadDraft(String draftId) async {
    if (!mounted) return;
    final draftBloc = context.read<DraftBloc>();
    draftBloc.add(DraftLoadByIdRequested(draftId));
  }

  Future<void> _restoreDraftData(DraftVendorEntity draft) async {
    if (!mounted) return;

    // First, restore all file data before updating UI
    File? restoredAadhaarFrontImage;
    File? restoredAadhaarBackImage;
    File? restoredPanCardFile;
    String? restoredPanCardFileName;
    File? restoredGstCertificateFile;
    String? restoredGstCertificateFileName;
    File? restoredBusinessRegistrationFile;
    String? restoredBusinessRegistrationFileName;
    File? restoredProfessionalLicenseFile;
    String? restoredProfessionalLicenseFileName;
    File? restoredAdditionalDocumentFile;
    String? restoredAdditionalDocumentFileName;
    List<File> restoredFrontStoreImages = [];
    Uint8List? restoredSignatureBytes;

    // Helper function to restore files
    Future<void> restoreFile(
      String? filePath,
      Function(File, String) onRestored,
    ) async {
      if (filePath == null || filePath.isEmpty) return;
      try {
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 0) {
            // Extract filename from path, handling both Windows and Unix paths
            final fileName = filePath.replaceAll('\\', '/').split('/').last;
            onRestored(file, fileName);
          } else {
            print('⚠️ File exists but is empty: $filePath');
          }
        } else {
          print('⚠️ File not found: $filePath');
        }
      } catch (e) {
        print('❌ Error restoring file from path $filePath: $e');
      }
    }

    try {
      // Restore Govt ID Proof Images
      if (draft.aadhaarFrontImagePath != null &&
          draft.aadhaarFrontImagePath!.isNotEmpty) {
        try {
          final file = File(draft.aadhaarFrontImagePath!);
          if (await file.exists()) {
            final fileSize = await file.length();
            if (fileSize > 0) {
              restoredAadhaarFrontImage = file;
            } else {
              print(
                '⚠️ Govt Id Proof Front Image file is empty: ${draft.aadhaarFrontImagePath}',
              );
            }
          } else {
            print(
              '⚠️ Govt Id Proof Front Image file not found: ${draft.aadhaarFrontImagePath}',
            );
          }
        } catch (e) {
          print('❌ Error restoring Govt Id Proof Front Image: $e');
        }
      }

      if (draft.aadhaarBackImagePath != null &&
          draft.aadhaarBackImagePath!.isNotEmpty) {
        try {
          final file = File(draft.aadhaarBackImagePath!);
          if (await file.exists()) {
            final fileSize = await file.length();
            if (fileSize > 0) {
              restoredAadhaarBackImage = file;
            } else {
              print(
                '⚠️ Govt Id Proof Back Image file is empty: ${draft.aadhaarBackImagePath}',
              );
            }
          } else {
            print(
              '⚠️ Govt Id Proof Back Image file not found: ${draft.aadhaarBackImagePath}',
            );
          }
        } catch (e) {
          print('❌ Error restoring Govt Id Proof Back Image: $e');
        }
      }

      // Restore document files
      await restoreFile(draft.panCardFilePath, (file, fileName) {
        restoredPanCardFile = file;
        restoredPanCardFileName = fileName;
      });

      await restoreFile(draft.gstCertificateFilePath, (file, fileName) {
        restoredGstCertificateFile = file;
        restoredGstCertificateFileName = fileName;
      });

      await restoreFile(draft.businessRegistrationFilePath, (file, fileName) {
        restoredBusinessRegistrationFile = file;
        restoredBusinessRegistrationFileName = fileName;
      });

      await restoreFile(draft.professionalLicenseFilePath, (file, fileName) {
        restoredProfessionalLicenseFile = file;
        restoredProfessionalLicenseFileName = fileName;
      });

      await restoreFile(draft.additionalDocumentFilePath, (file, fileName) {
        restoredAdditionalDocumentFile = file;
        restoredAdditionalDocumentFileName = fileName;
      });

      // Restore front store images
      for (final imagePath in draft.frontStoreImagePaths) {
        if (imagePath.isEmpty) continue;
        try {
          final file = File(imagePath);
          if (await file.exists()) {
            final fileSize = await file.length();
            if (fileSize > 0) {
              restoredFrontStoreImages.add(file);
            } else {
              print('⚠️ Front store image file is empty: $imagePath');
            }
          } else {
            print('⚠️ Front store image file not found: $imagePath');
          }
        } catch (e) {
          print('❌ Error restoring front store image from $imagePath: $e');
        }
      }
      if (restoredFrontStoreImages.isNotEmpty) {
        print(
          '✅ Restored ${restoredFrontStoreImages.length} front store image(s)',
        );
      } else if (draft.frontStoreImagePaths.isNotEmpty) {
        print(
          '⚠️ No front store images could be restored from ${draft.frontStoreImagePaths.length} path(s)',
        );
      }

      // Restore signature
      if (draft.signatureImagePath != null) {
        try {
          final signatureFile = File(draft.signatureImagePath!);
          if (await signatureFile.exists()) {
            final fileSize = await signatureFile.length();
            if (fileSize > 0) {
              final bytes = await signatureFile.readAsBytes();
              if (bytes.isNotEmpty) {
                restoredSignatureBytes = bytes;
              }
            }
          }
        } catch (e) {
          print('Error reading signature file: $e');
        }
      }
    } catch (e) {
      print('Error restoring files from draft: $e');
    }

    // Now update all UI state in a single setState call
    if (mounted) {
      setState(() {
        // Personal Details
        _firstNameController.text = draft.firstName;
        _lastNameController.text = draft.lastName;
        _emailController.text = draft.email;
        _passwordController.text = draft.password;
        _confirmPasswordController.text = draft.password;
        _phoneController.text = draft.mobile;
        _aadhaarNumberController.text = draft.aadhaarNumber;
        _residentialAddressController.text = draft.residentialAddress;

        // Business Details
        _businessNameController.text = draft.businessName;
        _businessLegalNameController.text = draft.businessLegalName;
        _businessEmailController.text = draft.businessEmail;
        _businessMobileController.text = draft.businessMobile;
        _altBusinessMobileController.text = draft.altBusinessMobile;
        _businessAddressController.text = draft.businessAddress;
        _selectedBusinessCategories = List<String>.from(draft.categories);

        // Banking Details
        _accountNumberController.text = draft.accountNumber;
        _confirmAccountNumberController.text = draft.accountNumber;
        _accountHolderNameController.text = draft.accountHolderName;
        _ifscCodeController.text = draft.ifscCode;
        _bankNameController.text = draft.bankName;
        _bankBranchController.text = draft.bankBranch;

        // Documents
        _panCardNumberController.text = draft.panCardNumber;
        _gstCertificateNumberController.text = draft.gstCertificateNumber;
        _businessRegistrationNumberController.text =
            draft.businessRegistrationNumber;
        _professionalLicenseNumberController.text =
            draft.professionalLicenseNumber;
        _additionalDocumentNameController.text = draft.additionalDocumentName;

        // Images and Files
        _aadhaarFrontImage = restoredAadhaarFrontImage;
        _aadhaarBackImage = restoredAadhaarBackImage;
        _panCardFile = restoredPanCardFile;
        _panCardFileName = restoredPanCardFileName;
        _gstCertificateFile = restoredGstCertificateFile;
        _gstCertificateFileName = restoredGstCertificateFileName;
        _businessRegistrationFile = restoredBusinessRegistrationFile;
        _businessRegistrationFileName = restoredBusinessRegistrationFileName;
        _professionalLicenseFile = restoredProfessionalLicenseFile;
        _professionalLicenseFileName = restoredProfessionalLicenseFileName;
        _additionalDocumentFile = restoredAdditionalDocumentFile;
        _additionalDocumentFileName = restoredAdditionalDocumentFileName;
        _frontStoreImages = restoredFrontStoreImages;
        _signatureBytes = restoredSignatureBytes;

        // Signature
        _signerNameController.text = draft.signerName ?? '';
        _acceptedTerms = draft.acceptedTerms;
      });
    }

    // Restore stepper state
    if (mounted) {
      final stepperBloc = context.read<VendorStepperBloc>();

      // Prepare expanded state - ensure current section is expanded
      final newExpanded = List<bool>.generate(6, (index) => false);
      // Expand current section
      if (draft.currentSectionIndex < newExpanded.length) {
        newExpanded[draft.currentSectionIndex] = true;
      }

      // Restore stepper state
      stepperBloc.add(
        VendorStepperRestoreState(
          currentSection: draft.currentSectionIndex,
          sectionValidations: List<bool>.from(draft.sectionValidations),
          sectionCompleted: List<bool>.from(draft.sectionCompleted),
          sectionExpanded: newExpanded,
        ),
      );

      // Trigger validation for restored sections to update UI
      for (int i = 0; i < draft.sectionValidations.length; i++) {
        if (draft.sectionValidations[i]) {
          stepperBloc.add(VendorStepperSectionValidated(i, true));
        }
      }

      // Navigate to the last active section after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && draft.currentSectionIndex < _sectionKeys.length) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _scrollToSection(draft.currentSectionIndex);
            }
          });
        }
      });
    }
  }

  Future<void> _prefillVendorDetails(VendorEntity vendor) async {
    if (!mounted) return;

    setState(() {
      // Personal Details
      _firstNameController.text = vendor.firstName;
      _lastNameController.text = vendor.lastName;
      _emailController.text = vendor.email;
      _phoneController.text = vendor.mobile;
      _aadhaarNumberController.text = vendor.adharnumber;
      _residentialAddressController.text = vendor.residentaladdress;
      _signerNameController.text = vendor.signname;

      // Business Details
      _businessNameController.text = vendor.businessName;
      _businessLegalNameController.text = vendor.bussinesslegalname;
      _businessEmailController.text = vendor.businessEmail;
      _businessMobileController.text = vendor.bussinessmobile;
      _altBusinessMobileController.text = vendor.altMobile;
      _businessAddressController.text = vendor.address;
      _selectedBusinessCategories = List<String>.from(vendor.categories);

      // Banking Details
      _accountNumberController.text = vendor.accountNumber;
      _confirmAccountNumberController.text = vendor.accountNumber;
      _accountHolderNameController.text = vendor.accountName;
      _ifscCodeController.text = vendor.ifscCode;
      _bankNameController.text = vendor.bankName;
      _bankBranchController.text = vendor.branchName;

      // Documents - Map document numbers based on docNames
      // Assuming order: PAN Card, GST Certificate, Business Registration, Professional License
      if (vendor.documentNumbers.isNotEmpty) {
        // Find PAN Card
        final panIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('pan'),
        );
        if (panIndex >= 0 && panIndex < vendor.documentNumbers.length) {
          _panCardNumberController.text = vendor.documentNumbers[panIndex];
        }

        // Find GST Certificate
        final gstIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('gst'),
        );
        if (gstIndex >= 0 && gstIndex < vendor.documentNumbers.length) {
          _gstCertificateNumberController.text =
              vendor.documentNumbers[gstIndex];
        }

        // Find Business Registration
        final brIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('business') ||
              name.toLowerCase().contains('registration'),
        );
        if (brIndex >= 0 && brIndex < vendor.documentNumbers.length) {
          _businessRegistrationNumberController.text =
              vendor.documentNumbers[brIndex];
        }

        // Find Professional License
        final plIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('professional') ||
              name.toLowerCase().contains('license'),
        );
        if (plIndex >= 0 && plIndex < vendor.documentNumbers.length) {
          _professionalLicenseNumberController.text =
              vendor.documentNumbers[plIndex];
        }
      }
    });

    // Update categories mapping after prefilling
    if (_categoriesLoaded) {
      _updateCategoryMappings();
    }
  }

  void _updateCategoryMappings() {
    // Update the category name to ID mappings
    for (final category in _availableCategories) {
      if (_selectedBusinessCategories.contains(category.id)) {
        _categoryNameToId[category.name] = category.id;
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final apiService = ApiService();
      final categoriesData = await apiService.getCategories(
        ApiEndpoints.getCategories,
      );
      final categories = categoriesData
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      setState(() {
        _availableCategories = categories;
        _categoryNameToId = {for (var cat in categories) cat.name: cat.id};
        _categoriesLoaded = true;
      });
    } catch (e) {
      setState(() => _categoriesLoaded = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveDraft() async {
    if (_currentDraftId == null || _isSavingDraft) return;
    _isSavingDraft = true;

    try {
      if (!mounted) return;

      final stepperState = context.read<VendorStepperBloc>().state;
      final draftBloc = context.read<DraftBloc>();

      // Extract form data
      final formData = DraftHelper.extractFormData(
        controllers: {
          'firstName': _firstNameController,
          'lastName': _lastNameController,
          'email': _emailController,
          'password': _passwordController,
          'mobile': _phoneController,
          'aadhaarNumber': _aadhaarNumberController,
          'residentialAddress': _residentialAddressController,
          'businessName': _businessNameController,
          'businessLegalName': _businessLegalNameController,
          'businessEmail': _businessEmailController,
          'businessMobile': _businessMobileController,
          'altBusinessMobile': _altBusinessMobileController,
          'businessAddress': _businessAddressController,
          'accountNumber': _accountNumberController,
          'accountHolderName': _accountHolderNameController,
          'ifscCode': _ifscCodeController,
          'bankName': _bankNameController,
          'bankBranch': _bankBranchController,
          'panCardNumber': _panCardNumberController,
          'gstCertificateNumber': _gstCertificateNumberController,
          'businessRegistrationNumber': _businessRegistrationNumberController,
          'professionalLicenseNumber': _professionalLicenseNumberController,
          'additionalDocumentName': _additionalDocumentNameController,
        },
        aadhaarFrontImage: _aadhaarFrontImage,
        aadhaarBackImage: _aadhaarBackImage,
        panCardFile: _panCardFile,
        gstCertificateFile: _gstCertificateFile,
        businessRegistrationFile: _businessRegistrationFile,
        professionalLicenseFile: _professionalLicenseFile,
        additionalDocumentFile: _additionalDocumentFile,
        frontStoreImages: _frontStoreImages,
        signatureBytes: _signatureBytes,
        categories: _selectedBusinessCategories,
        signerName: _signerNameController.text,
        acceptedTerms: _acceptedTerms,
      );

      // Create draft entity
      final draft = await DraftHelper.createDraftFromFormData(
        draftId: _currentDraftId!,
        stepperState: stepperState,
        formData: formData,
      );

      // Save draft if it has data
      if (draft != null && draft.hasAnyData) {
        if (mounted) {
          draftBloc.add(DraftSaveRequested(draft));
        }
      }
    } catch (e) {
      print('Error saving draft: $e');
    } finally {
      _isSavingDraft = false;
    }
  }

  @override
  void dispose() {
    // Note: We can't await in dispose, but PopScope handles saving before navigation
    // This is a fallback in case PopScope doesn't catch it
    _saveDraft();

    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadhaarNumberController.dispose();
    _residentialAddressController.dispose();
    _businessNameController.dispose();
    _businessLegalNameController.dispose();
    _businessEmailController.dispose();
    _businessMobileController.dispose();
    _altBusinessMobileController.dispose();
    _businessAddressController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _accountHolderNameController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _panCardNumberController.dispose();
    _gstCertificateNumberController.dispose();
    _businessRegistrationNumberController.dispose();
    _professionalLicenseNumberController.dispose();
    _additionalDocumentNameController.dispose();
    _signatureController.dispose();
    _signerNameController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      // Wait for the section animation to complete (300ms) plus a small buffer
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.0, // Scroll to the top of the section
          );
        }
      });
    }
  }

  void _onFileSelected(String fieldName, File? file, String? fileName) {
    setState(() {
      switch (fieldName) {
        case 'business_registration':
          _businessRegistrationFile = file;
          _businessRegistrationFileName = fileName;
          break;
        case 'gst_certificate':
          _gstCertificateFile = file;
          _gstCertificateFileName = fileName;
          break;
        case 'pan_card':
          _panCardFile = file;
          _panCardFileName = fileName;
          break;
        case 'professional_license':
          _professionalLicenseFile = file;
          _professionalLicenseFileName = fileName;
          break;
        case 'additional_document':
          _additionalDocumentFile = file;
          _additionalDocumentFileName = fileName;
          break;
      }
    });
  }

  Future<void> _onSubmit() async {
    // Step 1: Send OTP to mobile number from Authorized Personal Details
    final mobileNumber = _phoneController.text.trim();

    if (mobileNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid mobile number'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Store mobile number for vendor creation (must match exactly)
    _mobileNumberForOtp = mobileNumber;

    setState(() {
      _isOtpVerificationInProgress = true;
    });

    try {
      // Step 2: Call Send OTP API
      print('═══════════════════════════════════════════════════════');
      print('📱 STEP 1: Sending OTP');
      print('   Identifier: $mobileNumber');
      print('   Type: phone');
      print('   Usertype: app');
      print('═══════════════════════════════════════════════════════');
      final otpResponse = await _apiService.post(
        ApiEndpoints.sendVendorProfileOtp,
        {'identifier': mobileNumber, 'usertype': 'app', 'type': 'phone'},
        token: widget.user.token,
      );

      print('✅ OTP sent successfully');
      if (otpResponse['data']?['user']?['otp'] != null) {
        print('   OTP generated: ${otpResponse['data']['user']['otp']}');
      }

      if (!mounted) return;

      // Show success message when OTP is sent
      if (otpResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                otpResponse['message'] ?? 'OTP sent to your mobile number',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Step 3: Show OTP Dialog
      final otpVerified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => VendorOtpDialog(
          mobileNumber: mobileNumber,
          onVerify: (otp) async {
            // Store OTP for vendor creation
            // Backend will verify OTP when creating vendor
            print('✅ OTP verified and stored: $otp');
            _verifiedOtp = otp;
            return true;
          },
          onResend: () async {
            // Resend OTP
            final response = await _apiService.post(
              ApiEndpoints.sendVendorProfileOtp,
              {'identifier': mobileNumber, 'usertype': 'app', 'type': 'phone'},
              token: widget.user.token,
            );
            // Check if OTP was sent successfully
            if (response['success'] != true) {
              throw Exception(response['message'] ?? 'Failed to resend OTP');
            }
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    response['message'] ??
                        'OTP has been resent to your mobile number',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );

      setState(() {
        _isOtpVerificationInProgress = false;
      });

      // If user cancelled OTP dialog
      if (otpVerified != true) {
        return;
      }

      // Step 5: Create Vendor API (after OTP verification)
      await _createVendor();
    } catch (e) {
      setState(() {
        _isOtpVerificationInProgress = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send OTP: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createVendor() async {
    final categoryIds = _selectedBusinessCategories
        .map((name) => _categoryNameToId[name] ?? name)
        .where((id) => id.isNotEmpty)
        .toList();

    // Use the same mobile number that was used for OTP
    // This ensures the identifier matches exactly between send-otp and create vendor APIs
    final mobileForVendor = _mobileNumberForOtp ?? _phoneController.text.trim();

    print('\n═══════════════════════════════════════════════════════');
    print('📱 STEP 2: Creating Vendor');
    print('   Mobile (must match identifier from Step 1): $mobileForVendor');
    print('   OTP: ${_verifiedOtp ?? "❌ NULL - THIS WILL CAUSE ERROR!"}');
    print('   Type: phone');
    print('   Usertype: app');
    print('═══════════════════════════════════════════════════════');

    if (_verifiedOtp == null || _verifiedOtp!.isEmpty) {
      throw Exception(
        'OTP is required for vendor creation. Please verify OTP first.',
      );
    }

    if (mobileForVendor != _mobileNumberForOtp) {
      print('⚠️ WARNING: Mobile number mismatch!');
      print('   OTP was sent to: $_mobileNumberForOtp');
      print('   Vendor creation using: $mobileForVendor');
      print('   This will cause "No OTP request found" error!');
    }

    final vendor = VendorEntity(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      mobile: mobileForVendor,
      aadhaarFrontImage: _aadhaarFrontImage,
      aadhaarBackImage: _aadhaarBackImage,
      signname: _signerNameController.text,
      adharnumber: _aadhaarNumberController.text,
      residentaladdress: _residentialAddressController.text,
      businessName: _businessNameController.text,
      businessEmail: _businessEmailController.text,
      altMobile: _altBusinessMobileController.text,
      address: _businessAddressController.text,
      categories: categoryIds,
      bussinessmobile: _businessMobileController.text,
      bussinesslegalname: _businessLegalNameController.text,
      docNames: [
        'PAN Card',
        'GST Certificate',
        'Business Registration',
        'Professional License',
      ],
      docIds: [
        _panCardNumberController.text.isNotEmpty
            ? _panCardNumberController.text
            : 'PAN',
        _gstCertificateNumberController.text.isNotEmpty
            ? _gstCertificateNumberController.text
            : 'GST',
        _businessRegistrationNumberController.text.isNotEmpty
            ? _businessRegistrationNumberController.text
            : 'BR',
        _professionalLicenseNumberController.text.isNotEmpty
            ? _professionalLicenseNumberController.text
            : 'PL',
      ],
      documentNumbers: [
        _panCardNumberController.text,
        _gstCertificateNumberController.text,
        _businessRegistrationNumberController.text,
        _professionalLicenseNumberController.text,
      ],
      files: [
        _panCardFile,
        _gstCertificateFile,
        _businessRegistrationFile,
        _professionalLicenseFile,
      ],
      frontimages: [],
      backimages: [],
      signature: [],
      bankName: _bankNameController.text,
      accountName: _accountHolderNameController.text,
      accountNumber: _accountNumberController.text,
      ifscCode: _ifscCodeController.text,
      branchName: _bankBranchController.text,
      otp: _verifiedOtp, // Include verified OTP in vendor creation
      vendorId: widget.isEditMode && widget.vendorDetails != null
          ? widget.vendorDetails!.vendorId
          : null, // Include vendorId when editing
    );

    List<File> signatureFiles = [];
    if (_signatureBytes != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final signatureDir = Directory('${appDir.path}/signature');
        if (!await signatureDir.exists()) {
          await signatureDir.create(recursive: true);
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final signatureFile = File(
          '${signatureDir.path}/signature_$timestamp.png',
        );
        await signatureFile.writeAsBytes(_signatureBytes!);
        signatureFiles.add(signatureFile);
      } catch (e) {
        print('❌ Error creating signature file: $e');
      }
    }

    if (mounted) {
      context.read<VendorFormBloc>().add(
        VendorFormSubmitted(
          vendor,
          widget.user.token,
          frontimages: _frontStoreImages,
          backimages: [],
          signature: signatureFiles,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _aadhaarNumberController.clear();
      _residentialAddressController.clear();
      _aadhaarFrontImage = null;
      _aadhaarBackImage = null;
      _businessNameController.clear();
      _businessLegalNameController.clear();
      _businessEmailController.clear();
      _businessMobileController.clear();
      _altBusinessMobileController.clear();
      _businessAddressController.clear();
      _accountNumberController.clear();
      _confirmAccountNumberController.clear();
      _accountHolderNameController.clear();
      _ifscCodeController.clear();
      _bankNameController.clear();
      _bankBranchController.clear();
      _panCardNumberController.clear();
      _gstCertificateNumberController.clear();
      _businessRegistrationNumberController.clear();
      _professionalLicenseNumberController.clear();
      _additionalDocumentNameController.clear();
      _selectedBusinessCategories = [];
      _businessRegistrationFile = null;
      _gstCertificateFile = null;
      _panCardFile = null;
      _professionalLicenseFile = null;
      _additionalDocumentFile = null;
      _businessRegistrationFileName = null;
      _gstCertificateFileName = null;
      _panCardFileName = null;
      _professionalLicenseFileName = null;
      _additionalDocumentFileName = null;
      _frontStoreImages = [];
      _signatureController.clear();
      _signerNameController.clear();
      _signatureBytes = null;
      _acceptedTerms = false;
    });
    context.read<VendorStepperBloc>().add(VendorStepperReset());
    context.read<VendorFormBloc>().add(VendorFormReset());
  }

  Widget _buildSectionContent(int index, bool enabled) {
    switch (index) {
      case 0:
        return PersonalDetailsSection(
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          emailController: _emailController,
          phoneController: _phoneController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          aadhaarNumberController: _aadhaarNumberController,
          residentialAddressController: _residentialAddressController,
          aadhaarFrontImage: _aadhaarFrontImage,
          aadhaarBackImage: _aadhaarBackImage,
          enabled: enabled,
          onAadhaarFrontImageChanged: (photo) {
            setState(() => _aadhaarFrontImage = photo);
          },
          onAadhaarBackImageChanged: (photo) {
            setState(() => _aadhaarBackImage = photo);
          },
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(0, isValid),
            );
          },
        );
      case 1:
        return BusinessDetailsSection(
          businessNameController: _businessNameController,
          businessLegalNameController: _businessLegalNameController,
          businessEmailController: _businessEmailController,
          businessMobileController: _businessMobileController,
          altBusinessMobileController: _altBusinessMobileController,
          businessAddressController: _businessAddressController,
          selectedCategories: _selectedBusinessCategories,
          availableCategories: _availableCategories,
          categoriesLoaded: _categoriesLoaded,
          enabled: enabled,
          onCategoriesChanged: (categories) {
            setState(() => _selectedBusinessCategories = categories);
          },
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(1, isValid),
            );
          },
        );
      case 2:
        return BankingDetailsSection(
          accountNumberController: _accountNumberController,
          confirmAccountNumberController: _confirmAccountNumberController,
          accountHolderNameController: _accountHolderNameController,
          ifscCodeController: _ifscCodeController,
          bankNameController: _bankNameController,
          bankBranchController: _bankBranchController,
          enabled: enabled,
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(2, isValid),
            );
          },
        );
      case 3:
        return DocumentsSection(
          businessRegistrationFile: _businessRegistrationFile,
          gstCertificateFile: _gstCertificateFile,
          panCardFile: _panCardFile,
          professionalLicenseFile: _professionalLicenseFile,
          businessRegistrationFileName: _businessRegistrationFileName,
          gstCertificateFileName: _gstCertificateFileName,
          panCardFileName: _panCardFileName,
          professionalLicenseFileName: _professionalLicenseFileName,
          additionalDocumentFile: _additionalDocumentFile,
          additionalDocumentFileName: _additionalDocumentFileName,
          panCardNumberController: _panCardNumberController,
          gstCertificateNumberController: _gstCertificateNumberController,
          businessRegistrationNumberController:
              _businessRegistrationNumberController,
          professionalLicenseNumberController:
              _professionalLicenseNumberController,
          additionalDocumentNameController: _additionalDocumentNameController,
          enabled: enabled,
          onFileSelected: _onFileSelected,
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(3, isValid),
            );
          },
        );
      case 4:
        return PhotosSection(
          frontStoreImages: _frontStoreImages,
          enabled: enabled,
          onFrontStoreImagesChanged: (images) =>
              setState(() => _frontStoreImages = images),
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(4, isValid),
            );
          },
        );
      case 5:
        return SignatureSection(
          signatureController: _signatureController,
          signerNameController: _signerNameController,
          signatureBytes: _signatureBytes,
          acceptedTerms: _acceptedTerms,
          enabled: enabled,
          onSignatureSaved: (bytes) => setState(() => _signatureBytes = bytes),
          onTermsChanged: (value) => setState(() => _acceptedTerms = value),
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(5, isValid),
            );
          },
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DraftBloc, DraftState>(
          listener: (context, draftState) {
            if (draftState is DraftLoaded) {
              _restoreDraftData(draftState.draft);
            } else if (draftState is DraftError) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading draft: ${draftState.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
        BlocListener<VendorFormBloc, VendorFormState>(
          listener: (context, state) {
            if (state is VendorFormSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Success!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Vendor created successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'OK',
                            onPressed: () async {
                              // Delete draft on successful submission
                              if (_currentDraftId != null) {
                                try {
                                  context.read<DraftBloc>().add(
                                    DraftDeleteRequested(_currentDraftId!),
                                  );
                                } catch (e) {
                                  print('Error deleting draft: $e');
                                }
                              }
                              Navigator.of(
                                context,
                              ).pop(); // Close success dialog
                              _resetForm();
                              // Navigate back to Dashboard (pop all routes until Dashboard)
                              Navigator.of(context).popUntil((route) {
                                // Pop until we reach Dashboard or root
                                return route.isFirst ||
                                    route.settings.name == '/dashboard';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is VendorFormFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocConsumer<VendorStepperBloc, VendorStepperState>(
        listenWhen: (previous, current) {
          // Listen when expanded state or current section changes
          return previous.sectionExpanded != current.sectionExpanded ||
              previous.currentSection != current.currentSection;
        },
        listener: (context, state) {
          // Initialize previous state if null
          if (_previousExpandedState == null) {
            _previousExpandedState = List.from(state.sectionExpanded);
            _previousCurrentSection = state.currentSection;
            return;
          }

          final currentSection = state.currentSection;
          final isCurrentSectionExpanded =
              currentSection < state.sectionExpanded.length &&
              state.sectionExpanded[currentSection];

          // Check if current section changed (Next/Previous button pressed)
          bool currentSectionChanged =
              _previousCurrentSection != currentSection;

          // Check if current section was just expanded
          bool wasJustExpanded =
              currentSection < _previousExpandedState!.length &&
              !_previousExpandedState![currentSection] &&
              isCurrentSectionExpanded;

          // Scroll to current section if:
          // 1. Current section changed (Next/Previous button) AND it's expanded, OR
          // 2. Current section was just expanded
          if (isCurrentSectionExpanded &&
              (currentSectionChanged || wasJustExpanded)) {
            _scrollToSection(currentSection);
          }

          _previousExpandedState = List.from(state.sectionExpanded);
          _previousCurrentSection = currentSection;
        },
        builder: (context, stepperState) {
          return BlocBuilder<VendorFormBloc, VendorFormState>(
            builder: (context, formState) {
              final isSubmitting = formState is VendorFormSubmitting;

              return PopScope(
                canPop: false,
                onPopInvoked: (didPop) async {
                  if (didPop) return;
                  // Save draft before navigating back
                  await _saveDraft();
                  // Small delay to ensure draft is saved
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (mounted) {
                    // If we came from DraftListScreen (resuming a draft), pop twice to go to Dashboard
                    // Otherwise, just pop once
                    if (widget.draftId != null) {
                      // Resuming draft - pop twice to skip DraftListScreen
                      Navigator.of(context).pop(); // Pop VendorProfileScreen
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // Pop DraftListScreen
                      }
                    } else {
                      Navigator.of(context).pop(); // Normal navigation back
                    }
                  }
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: const Text('Complete Vendor Profile'),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    surfaceTintColor: Colors.transparent,
                  ),
                  body: Column(
                    children: [
                      // Progress indicator
                      _buildProgressHeader(stepperState),
                      // Sections list
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: List.generate(_sections.length, (index) {
                              final section = _sections[index];
                              final isExpanded =
                                  stepperState.sectionExpanded[index];
                              final isCompleted =
                                  stepperState.sectionCompleted[index];
                              final isEnabled = stepperState.isSectionEnabled(
                                index,
                              );
                              final isActive =
                                  stepperState.currentSection == index;

                              return Column(
                                key: _sectionKeys[index],
                                children: [
                                  SectionHeader(
                                    index: index,
                                    title: section.title,
                                    icon: section.icon,
                                    isExpanded: isExpanded,
                                    isCompleted: isCompleted,
                                    isEnabled: isEnabled,
                                    isActive: isActive,
                                    onTap: () {
                                      context.read<VendorStepperBloc>().add(
                                        VendorStepperSectionTapped(index),
                                      );
                                    },
                                  ),
                                  AnimatedSectionContainer(
                                    isExpanded: isExpanded,
                                    child: _buildSectionContent(
                                      index,
                                      !isSubmitting &&
                                          !_isOtpVerificationInProgress,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      // Navigation buttons
                      StepperNavigationButtons(
                        isFirstSection: stepperState.isFirstSection,
                        isLastSection: stepperState.isLastSection,
                        canProceed: stepperState.canProceed,
                        isSubmitting:
                            isSubmitting || _isOtpVerificationInProgress,
                        onPrevious: () {
                          context.read<VendorStepperBloc>().add(
                            VendorStepperPreviousPressed(),
                          );
                        },
                        onNext: () {
                          context.read<VendorStepperBloc>().add(
                            VendorStepperNextPressed(),
                          );
                        },
                        onSubmit: _onSubmit,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(VendorStepperState state) {
    final completedCount = state.sectionCompleted.where((c) => c).length;
    final progress =
        (state.currentSection + 1) / VendorStepperState.totalSections;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${state.currentSection + 1} of ${VendorStepperState.totalSections}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount completed',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  final String title;
  final IconData icon;

  _SectionData(this.title, this.icon);
}
