import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/draft_vendor_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
import '../../../domain/repositories/draft_repository.dart';
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
import 'models/additional_document_model.dart';
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
  final _aadhaarNumberController = TextEditingController();
  final _residentialAddressController = TextEditingController();
  File? _aadhaarFrontImage;
  File? _aadhaarBackImage;
  String? _aadhaarFrontImageUrl;
  String? _aadhaarBackImageUrl;

  // Controllers - Business Details
  final _businessNameController = TextEditingController();
  final _businessLegalNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessMobileController = TextEditingController();
  final _altBusinessMobileController = TextEditingController();
  final _businessAddressController = TextEditingController();
  double? _businessLatitude;
  double? _businessLongitude;

  // Controllers - Banking Details
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();

  // Controllers  // Documents
  final TextEditingController _panCardNumberController =
      TextEditingController();
  final TextEditingController _gstCertificateNumberController =
      TextEditingController();
  final TextEditingController _businessRegistrationNumberController =
      TextEditingController();
  final TextEditingController _professionalLicenseNumberController =
      TextEditingController();

  // Dynamic Additional Documents
  List<AdditionalDocumentModel> _additionalDocuments = [];

  final TextEditingController _panCardExpiryDateController =
      TextEditingController();
  final TextEditingController _gstExpiryDateController =
      TextEditingController();
  final TextEditingController _businessRegistrationExpiryDateController =
      TextEditingController();
  final TextEditingController _professionalLicenseExpiryDateController =
      TextEditingController();

  // Signature
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  final _signerNameController = TextEditingController();
  Uint8List? _signatureBytes;
  String? _signatureImageUrl;

  // Categories
  List<String> _selectedBusinessCategories = [];
  List<CategoryModel> _availableCategories = [];
  Map<String, String> _categoryNameToId = {};
  Map<String, String> _categoryIdToName = {}; // New map for ID -> Name
  bool _categoriesLoaded = false;

  // Files
  File? _businessRegistrationFile;
  File? _gstCertificateFile;
  File? _panCardFile;
  File? _professionalLicenseFile;
  String? _businessRegistrationFileName;
  String? _gstCertificateFileName;
  String? _panCardFileName;
  String? _professionalLicenseFileName;

  // URL Variables for Edit Mode
  String? _businessRegistrationUrl;
  String? _gstCertificateUrl;
  String? _panCardUrl;
  String? _professionalLicenseUrl;

  // Additional documents files are managed inside _additionalDocuments list

  File? _storeLogo;
  File? _profileBanner;

  String? _storeLogoUrl;
  String? _profileBannerUrl;

  // Images
  List<File> _frontStoreImages = [];
  List<String> _frontStoreImageUrls = [];

  // Re-upload status tracking (local state to change rejected -> pending)
  bool _aadhaarFrontReuploaded = false;
  bool _aadhaarBackReuploaded = false;
  bool _signatureReuploaded = false;
  Map<String, bool> _documentsReuploaded =
      {}; // Track by document key (e.g., 'pan_card')

  // Terms
  bool _acceptedTerms = false;
  bool _consentAccepted = false;
  bool _pricingAgreementAccepted = false;
  bool _slvAgreementAccepted = false;

  // OTP verification state
  bool _isOtpVerificationInProgress = false;
  String? _verifiedOtp; // Store verified OTP
  String?
  _mobileNumberForOtp; // Store mobile number used for OTP (must match in vendor creation)
  final ApiService _apiService = ApiService();

  // ID Proof Type
  String? _selectedIdProofType;

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
    List<File> restoredFrontStoreImages = [];
    File? restoredStoreLogo;
    File? restoredProfileBanner;
    Uint8List? restoredSignatureBytes;

    // Declare here to be visible in setState later
    List<AdditionalDocumentModel> restoredAdditionalDocuments = [];

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
      // Restore ID Proof Images
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

      // Restore additional documents
      restoredAdditionalDocuments = [];
      for (final doc in draft.additionalDocuments) {
        File? docFile;
        final docPath = doc['filePath'];
        if (docPath != null && docPath.isNotEmpty) {
          try {
            final file = File(docPath);
            if (await file.exists()) {
              final fileSize = await file.length();
              if (fileSize > 0) {
                docFile = file;
              }
            }
          } catch (e) {
            print('❌ Error restoring additional document file: $e');
          }
        }
        restoredAdditionalDocuments.add(
          AdditionalDocumentModel(
            name: doc['name'] ?? '',
            number: doc['number'] ?? '',
            expiryDate: doc['expiryDate'] ?? '',
            file: docFile,
            fileName: docFile?.path.split('/').last,
            fileUrl: docPath, // Use filePath as URL equivalent for draft
          ),
        );
      }

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

      // Restore Store Logo
      await restoreFile(draft.storeLogoPath, (file, fileName) {
        restoredStoreLogo = file;
      });

      // Restore Profile Banner
      await restoreFile(draft.profileBannerPath, (file, fileName) {
        restoredProfileBanner = file;
      });

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
        _phoneController.text = draft.mobile;
        _aadhaarNumberController.text = draft.aadhaarNumber;
        _selectedIdProofType = draft.idProofType ?? 'Aadhar';
        _residentialAddressController.text = draft.residentialAddress;

        // Business Details
        _businessNameController.text = draft.businessName;
        _businessLegalNameController.text = draft.businessLegalName;
        _businessEmailController.text = draft.businessEmail;
        _businessMobileController.text = draft.businessMobile;
        _altBusinessMobileController.text = draft.altBusinessMobile;
        _businessAddressController.text = draft.businessAddress;
        _businessLatitude = draft.latitude;
        _businessLongitude = draft.longitude;
        // Convert IDs to Names if map is available, otherwise keep IDs (will be fixed in fetchCategories)
        _selectedBusinessCategories = draft.categories.map((c) {
          // If it looks like an ID (and we have a name for it), use the name
          if (_categoryIdToName.containsKey(c)) {
            return _categoryIdToName[c]!;
          }
          // Check if it's already a name (exists in nameToId)
          if (_categoryNameToId.containsKey(c)) {
            return c;
          }
          return c;
        }).toList();

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
        _panCardExpiryDateController.text = draft.panCardExpiryDate ?? '';
        _gstExpiryDateController.text = draft.gstExpiryDate ?? '';
        _businessRegistrationExpiryDateController.text =
            draft.businessRegistrationExpiryDate ?? '';
        _professionalLicenseExpiryDateController.text =
            draft.professionalLicenseExpiryDate ?? '';

        // Additional Documents
        _additionalDocuments = restoredAdditionalDocuments;

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
        _frontStoreImages = restoredFrontStoreImages;
        _storeLogo = restoredStoreLogo;
        _profileBanner = restoredProfileBanner;
        _signatureBytes = restoredSignatureBytes;

        // Signature
        _signerNameController.text = draft.signerName ?? '';
        _acceptedTerms = draft.acceptedTerms;
        _consentAccepted = draft.consentAccepted;
        _pricingAgreementAccepted = draft.pricingAgreementAccepted;
        _slvAgreementAccepted = draft.slvAgreementAccepted;
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

  String _formatExpiryDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _prefillVendorDetails(VendorEntity vendor) async {
    if (!mounted) return;

    setState(() {
      // Personal Details
      _firstNameController.text = vendor.firstName;
      _lastNameController.text = vendor.lastName;
      _emailController.text = vendor.email;
      // Helper to sanitize mobile (keep last 10 digits)
      String sanitizeMobile(String val) {
        final digits = val.replaceAll(RegExp(r'\D'), '');
        if (digits.length > 10) return digits.substring(digits.length - 10);
        return digits;
      }

      _phoneController.text = sanitizeMobile(vendor.mobile);

      // Clean ID Number (remove spaces/dashes)
      String cleanIdNumber = vendor.adharnumber.replaceAll(
        RegExp(r'[\s-]'),
        '',
      );

      // Robust ID Proof Type Handling
      String? proofType = vendor.proofType;

      // 1. Try to infer from content if missing
      if (proofType == null || proofType.isEmpty) {
        // Check for PAN pattern (ABCDE1234F)
        if (RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleanIdNumber)) {
          proofType = 'PAN Card';
        } else {
          // Default to Aadhar
          proofType = 'Aadhar';
        }
      }

      // 2. Normalize typical variations
      if (proofType.toLowerCase().contains('adhar') ||
          proofType.toLowerCase().contains('aadhaar')) {
        proofType = 'Aadhar';
      }

      _aadhaarNumberController.text = cleanIdNumber;
      _selectedIdProofType = proofType;
      _residentialAddressController.text = vendor.residentaladdress;
      _signerNameController.text = vendor.signname;
      _aadhaarFrontImageUrl = vendor.aadhaarFrontImageUrl;
      _aadhaarBackImageUrl = vendor.aadhaarBackImageUrl;

      // Business Details
      _businessNameController.text = vendor.businessName;
      _businessLegalNameController.text = vendor.bussinesslegalname;
      _businessEmailController.text = vendor.businessEmail;
      _businessMobileController.text = sanitizeMobile(vendor.bussinessmobile);
      _altBusinessMobileController.text = sanitizeMobile(vendor.altMobile);
      _businessAddressController.text = vendor.address;
      _businessLatitude = vendor.latitude;
      _businessLongitude = vendor.longitude;

      // Convert IDs to Names
      _selectedBusinessCategories = vendor.categories.map((id) {
        return _categoryIdToName[id] ?? id;
      }).toList();

      // Banking Details
      _accountNumberController.text = vendor.accountNumber;
      _confirmAccountNumberController.text = vendor.accountNumber;
      _accountHolderNameController.text = vendor.accountName;
      _ifscCodeController.text = vendor.ifscCode;
      _bankNameController.text = vendor.bankName;
      _bankBranchController.text = vendor.branchName;

      // Documents - Map document numbers AND URLs based on docNames
      // Assuming order: PAN Card, GST Certificate, Business Registration, Professional License
      // Note: vendor.docUrls aligns with vendor.docNames
      if (vendor.documentNumbers.isNotEmpty) {
        // Find PAN Card
        final panIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('pan'),
        );
        if (panIndex >= 0) {
          if (panIndex < vendor.documentNumbers.length)
            _panCardNumberController.text = vendor.documentNumbers[panIndex];
          if (panIndex < vendor.docUrls.length)
            _panCardUrl = vendor.docUrls[panIndex];
          if (panIndex < vendor.expiryDates.length)
            _panCardExpiryDateController.text = _formatExpiryDate(
              vendor.expiryDates[panIndex],
            );
        }

        // Find GST Certificate
        final gstIndex = vendor.docNames.indexWhere(
          (name) => name.toLowerCase().contains('gst'),
        );
        if (gstIndex >= 0) {
          if (gstIndex < vendor.documentNumbers.length)
            _gstCertificateNumberController.text =
                vendor.documentNumbers[gstIndex];
          if (gstIndex < vendor.docUrls.length)
            _gstCertificateUrl = vendor.docUrls[gstIndex];
          if (gstIndex < vendor.expiryDates.length)
            _gstExpiryDateController.text = _formatExpiryDate(
              vendor.expiryDates[gstIndex],
            );
        }

        // Find Business Registration
        final brIndex = vendor.docNames.indexWhere(
          (name) =>
              name.toLowerCase().contains('business') ||
              name.toLowerCase().contains('registration'),
        );
        if (brIndex >= 0) {
          if (brIndex < vendor.documentNumbers.length)
            _businessRegistrationNumberController.text =
                vendor.documentNumbers[brIndex];
          if (brIndex < vendor.docUrls.length)
            _businessRegistrationUrl = vendor.docUrls[brIndex];
          if (brIndex < vendor.expiryDates.length)
            _businessRegistrationExpiryDateController.text = _formatExpiryDate(
              vendor.expiryDates[brIndex],
            );
        }

        // Find Professional License
        final plIndex = vendor.docNames.indexWhere(
          (name) =>
              name.toLowerCase().contains('professional') ||
              name.toLowerCase().contains('license'),
        );
        if (plIndex >= 0) {
          if (plIndex < vendor.documentNumbers.length)
            _professionalLicenseNumberController.text =
                vendor.documentNumbers[plIndex];
          if (plIndex < vendor.docUrls.length)
            _professionalLicenseUrl = vendor.docUrls[plIndex];
          if (plIndex < vendor.expiryDates.length)
            _professionalLicenseExpiryDateController.text = _formatExpiryDate(
              vendor.expiryDates[plIndex],
            );
        }

        // Populate Additional Documents
        // Filter out mandatory documents to find additional ones
        final mandatoryDocNames = [
          'PAN Card',
          'GST Certificate',
          'Business Registration',
          'Professional License',
        ];

        _additionalDocuments = [];
        // docNames is non-nullable list
        for (int i = 0; i < vendor.docNames.length; i++) {
          final docName = vendor.docNames[i];
          // Check if this document name is not one of the mandatory ones
          if (!mandatoryDocNames.any(
            (mName) => docName.toLowerCase().contains(mName.toLowerCase()),
          )) {
            // This is an additional document
            final doc = AdditionalDocumentModel(
              name: docName,
              number: (i < vendor.documentNumbers.length)
                  ? vendor.documentNumbers[i]
                  : '',
              expiryDate: (i < vendor.expiryDates.length)
                  ? _formatExpiryDate(vendor.expiryDates[i])
                  : '',
            );
            // Try to find file/url if available
            if (i < vendor.docUrls.length) {
              doc.fileUrl = vendor.docUrls[i];
            }
            _additionalDocuments.add(doc);
          }
        }
      }

      // Images & Signature
      _storeLogoUrl = vendor.storeLogoUrl;
      _profileBannerUrl = vendor.profileBannerUrl;
      _frontStoreImageUrls = vendor.frontImageUrls ?? [];
      _signatureImageUrl = vendor.signatureImageUrl;

      // Agreements
      _acceptedTerms =
          true; // If they are an existing vendor, they must have accepted terms
      _consentAccepted = vendor.consentAccepted;
      _pricingAgreementAccepted = vendor.pricingAgreementAccepted;
      _slvAgreementAccepted = vendor.slvAgreementAccepted;
    });

    // No need to update category mappings explicitly as fetchCategories handles full mapping
    // and we are using the full map now.

    // Initialize Stepper State for Edit Mode
    // Since this is an existing vendor, we assume all sections are initially valid and completed.
    if (mounted) {
      final stepperBloc = context.read<VendorStepperBloc>();

      // All 6 sections valid & completed
      final allValid = List<bool>.generate(6, (_) => true);
      final allCompleted = List<bool>.generate(6, (_) => true);

      // Start at first section
      final newExpanded = List<bool>.generate(6, (index) => index == 0);

      stepperBloc.add(
        VendorStepperRestoreState(
          currentSection: 0,
          sectionValidations: allValid,
          sectionCompleted: allCompleted,
          sectionExpanded: newExpanded,
        ),
      );
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
        _categoryIdToName = {for (var cat in categories) cat.id: cat.name};

        // Convert currently selected IDs to Names if any
        _selectedBusinessCategories = _selectedBusinessCategories.map((c) {
          // If 'c' is an ID in our map, swap to Name
          if (_categoryIdToName.containsKey(c)) {
            return _categoryIdToName[c]!;
          }
          return c;
        }).toList();

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
      final formData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'mobile': _phoneController.text, // Mobile from Personal Details
        'email': _emailController.text,
        'businessName': _businessNameController.text,
        'businessLegalName': _businessLegalNameController.text,
        'businessEmail': _businessEmailController.text,
        'businessMobile': _businessMobileController.text,
        'altBusinessMobile': _altBusinessMobileController.text,
        'businessAddress': _businessAddressController.text,
        'accountNumber': _accountNumberController.text,
        'accountHolderName': _accountHolderNameController.text,
        'ifscCode': _ifscCodeController.text,
        'bankName': _bankNameController.text,
        'bankBranch': _bankBranchController.text,
        'panCardNumber': _panCardNumberController.text,
        'gstCertificateNumber': _gstCertificateNumberController.text,
        'businessRegistrationNumber':
            _businessRegistrationNumberController.text,
        'professionalLicenseNumber': _professionalLicenseNumberController.text,
        'panCardExpiryDate': _panCardExpiryDateController.text,
        'gstExpiryDate': _gstExpiryDateController.text,
        'businessRegistrationExpiryDate':
            _businessRegistrationExpiryDateController.text,
        'professionalLicenseExpiryDate':
            _professionalLicenseExpiryDateController.text,
        'additionalDocuments': _additionalDocuments, // Pass the list model
        'businessRegistrationFile': _businessRegistrationFile,
        'gstCertificateFile': _gstCertificateFile,
        'panCardFile': _panCardFile,
        'professionalLicenseFile': _professionalLicenseFile,
        'frontStoreImages': _frontStoreImages,
        'storeLogo': _storeLogo,
        'profileBanner': _profileBanner,
        'signatureBytes': _signatureBytes,
        'categories': _selectedBusinessCategories
            .map((name) => _categoryNameToId[name] ?? name)
            .toList(), // Convert Names to IDs for storage
        'latitude': _businessLatitude,
        'longitude': _businessLongitude,
        'aadhaarNumber': _aadhaarNumberController.text,
        'residentialAddress': _residentialAddressController.text,
        'aadhaarFrontImage': _aadhaarFrontImage,
        'aadhaarBackImage': _aadhaarBackImage,
        'signerName': _signerNameController.text,
        'idProofType': _selectedIdProofType,
        'acceptedTerms': _acceptedTerms,
        'consentAccepted': _consentAccepted,
        'pricingAgreementAccepted': _pricingAgreementAccepted,
        'slvAgreementAccepted': _slvAgreementAccepted,
      };

      // Check if a draft already exists for this vendor (by business name + mobile)
      // This prevents duplicate drafts for the same vendor
      final businessName = _businessNameController.text.trim();
      final mobile = _phoneController.text.trim();

      if (businessName.isNotEmpty &&
          mobile.isNotEmpty &&
          widget.draftId == null) {
        try {
          final draftRepo = sl<DraftRepository>();
          final existingDraft = await draftRepo.findDraftByVendorKey(
            businessName: businessName,
            mobile: mobile,
          );

          if (existingDraft != null && existingDraft.id != _currentDraftId) {
            // Found an existing draft - use its ID to update it
            print('📋 Found existing draft for $businessName ($mobile)');
            print(
              '   Reusing draft ID: ${existingDraft.id} (instead of $_currentDraftId)',
            );
            _currentDraftId = existingDraft.id;
          }
        } catch (e) {
          print('Error checking for existing draft: $e');
          // Continue with current draft ID if check fails
        }
      }

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

    // Dispose dynamic documents
    for (var doc in _additionalDocuments) {
      doc.dispose();
    }

    _panCardExpiryDateController.dispose();
    _gstExpiryDateController.dispose();
    _businessRegistrationExpiryDateController.dispose();
    _professionalLicenseExpiryDateController.dispose();
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
      }
    });
  }

  void _addAdditionalDocument() {
    setState(() {
      _additionalDocuments.add(AdditionalDocumentModel());
    });
  }

  void _removeAdditionalDocument(int index) {
    setState(() {
      _additionalDocuments[index].dispose();
      _additionalDocuments.removeAt(index);
    });
  }

  void _onAdditionalDocumentFileSelected(
    int index,
    File? file,
    String? fileName,
  ) {
    setState(() {
      _additionalDocuments[index].file = file;
      _additionalDocuments[index].fileName = fileName;
    });
  }

  bool _validateRejectedDocuments() {
    final vendor = widget.vendorDetails;
    if (vendor == null) return true; // Not editing, so no rejections to check

    bool isRejected(String? status) => status?.toLowerCase() == 'rejected';

    // 1. Aadhaar
    if (isRejected(vendor.adhaarfrontimagestatus) && !_aadhaarFrontReuploaded) {
      _showError('Please re-upload rejected Aadhaar Front Image');
      return false;
    }
    if (isRejected(vendor.adhaarbackimagestatus) && !_aadhaarBackReuploaded) {
      _showError('Please re-upload rejected Aadhaar Back Image');
      return false;
    }

    // 2. Signature
    if (isRejected(vendor.signatureStatus) && !_signatureReuploaded) {
      _showError('Please re-sign rejected Signature');
      return false;
    }

    // 3. Documents
    if (vendor.documentStatuses != null) {
      for (final docStatus in vendor.documentStatuses!) {
        if (isRejected(docStatus['isVerified']?.toString())) {
          final docName =
              docStatus['name']?.toString().toLowerCase().trim() ?? '';

          bool reuploaded = false;

          if (docName.contains('pan')) {
            reuploaded = _documentsReuploaded['pan_card'] ?? false;
          } else if (docName.contains('gst')) {
            reuploaded = _documentsReuploaded['gst_certificate'] ?? false;
          } else if (docName.contains('business') ||
              docName.contains('registration')) {
            reuploaded = _documentsReuploaded['business_registration'] ?? false;
          } else if (docName.contains('professional') ||
              docName.contains('license')) {
            reuploaded = _documentsReuploaded['professional_license'] ?? false;
          } else {
            // Additional Document
            // Check if it exists in current list and has a new file
            final existing = _additionalDocuments.firstWhere(
              (d) => d.nameController.text.toLowerCase().trim() == docName,
              orElse: () => AdditionalDocumentModel(name: ''), // Dummy
            );

            if (existing.nameController.text.isNotEmpty) {
              // Document still exists in the form
              reuploaded = existing.file != null; // True if new file picked
            } else {
              // Document was removed by user
              reuploaded = true; // Treated as resolved (removed)
            }
          }

          if (!reuploaded) {
            _showError(
              'Please re-upload rejected document: ${docStatus['name']}',
            );
            return false;
          }
        }
      }
    }

    return true;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSubmit() async {
    // Validate rejected documents before proceeding
    if (!_validateRejectedDocuments()) {
      return;
    }

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

    // If Edit Mode, skip OTP verification
    if (widget.isEditMode) {
      await _createVendor();
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

    // Use the same mobile number that was used for OTP, but handle potential double-91 prefix
    var mobileForVendor = _mobileNumberForOtp ?? _phoneController.text.trim();

    print('\n═══════════════════════════════════════════════════════════════');
    print('📱 STEP 2: Creating/Updating Vendor');
    print('   Mobile: $mobileForVendor');
    if (!widget.isEditMode) {
      print('   OTP: ${_verifiedOtp ?? "❌ NULL - CANNOT PROCEED!"}');
    } else {
      print('   OTP: Skipped (Edit Mode)');
    }
    print('   Type: phone');
    print('   Usertype: app');
    print('═══════════════════════════════════════════════════════════════');

    // OTP Check only for non-edit mode (Creation)
    if (!widget.isEditMode && (_verifiedOtp == null || _verifiedOtp!.isEmpty)) {
      throw Exception(
        'OTP is required for vendor creation. Please verify OTP first.',
      );
    }

    if (!widget.isEditMode && mobileForVendor != _mobileNumberForOtp) {
      print('⚠️ WARNING: Mobile number mismatch!');
      print('   OTP was sent to: $_mobileNumberForOtp');
      print('   Vendor creation using: $mobileForVendor');
      print('   This will cause "No OTP request found" error!');
    }

    final vendor = VendorEntity(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: '', // Password is not collected in this flow
      mobile: mobileForVendor,
      aadhaarFrontImage: _aadhaarFrontImage,
      aadhaarBackImage: _aadhaarBackImage,
      signname: _signerNameController.text,
      adharnumber: _aadhaarNumberController.text,
      residentaladdress: _residentialAddressController.text,
      proofType: _selectedIdProofType,
      businessName: _businessNameController.text,
      businessEmail: _businessEmailController.text,
      altMobile: _altBusinessMobileController.text,
      address: _businessAddressController.text,
      latitude: _businessLatitude,
      longitude: _businessLongitude,
      categories: categoryIds,
      bussinessmobile: _businessMobileController.text,
      bussinesslegalname: _businessLegalNameController.text,
      docNames: [
        'PAN Card',
        'GST Certificate',
        'Business Registration',
        'Professional License',
        // Add names from dynamic additional documents
        ..._additionalDocuments.map((doc) => doc.nameController.text),
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
        // Add IDs for additional docs (using number as ID placeholder or 'ADDITIONAL')
        ..._additionalDocuments.map((doc) => 'ADDITIONAL'),
      ],
      documentNumbers: [
        _panCardNumberController.text,
        _gstCertificateNumberController.text,
        _businessRegistrationNumberController.text,
        _professionalLicenseNumberController.text,
        // Add numbers from additional documents
        ..._additionalDocuments.map((doc) => doc.numberController.text),
      ],
      expiryDates: [
        _panCardExpiryDateController.text,
        _gstExpiryDateController.text,
        _businessRegistrationExpiryDateController.text,
        _professionalLicenseExpiryDateController.text,
        // Add expiry dates from additional documents
        ..._additionalDocuments.map((doc) => doc.expiryDateController.text),
      ],
      files: [
        _panCardFile,
        _gstCertificateFile,
        _businessRegistrationFile,
        _professionalLicenseFile,
        // Add files from additional documents
        ..._additionalDocuments.map((doc) => doc.file),
      ],
      docUrls: [
        _panCardFile != null ? '' : (_panCardUrl ?? ''),
        _gstCertificateFile != null ? '' : (_gstCertificateUrl ?? ''),
        _businessRegistrationFile != null
            ? ''
            : (_businessRegistrationUrl ?? ''),
        _professionalLicenseFile != null ? '' : (_professionalLicenseUrl ?? ''),
        // Add URLs from additional documents
        ..._additionalDocuments.map(
          (doc) => doc.file != null ? '' : (doc.fileUrl ?? ''),
        ),
      ],
      frontimages: _frontStoreImages,
      frontImageUrls: _frontStoreImageUrls,
      backimages: [],
      signature: [],
      storeLogo: _storeLogo,
      storeLogoUrl: _storeLogoUrl,
      profileBanner: _profileBanner,
      profileBannerUrl: _profileBannerUrl,
      bankName: _bankNameController.text,
      accountName: _accountHolderNameController.text,
      accountNumber: _accountNumberController.text,
      ifscCode: _ifscCodeController.text,
      branchName: _bankBranchController.text,
      otp: _verifiedOtp, // Include verified OTP in vendor creation
      vendorId: widget.isEditMode && widget.vendorDetails != null
          ? widget.vendorDetails!.vendorId
          : null, // Include vendorId when editing
      consentAccepted: _consentAccepted,
      pricingAgreementAccepted: _pricingAgreementAccepted,
      slvAgreementAccepted: _slvAgreementAccepted,
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
      _aadhaarNumberController.clear();
      _selectedIdProofType = null;
      _residentialAddressController.clear();
      _aadhaarFrontImage = null;
      _aadhaarBackImage = null;
      _aadhaarFrontImageUrl = null;
      _aadhaarBackImageUrl = null;
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
      _professionalLicenseNumberController.clear();
      _additionalDocuments.forEach((doc) => doc.dispose());
      _additionalDocuments.clear();
      _selectedBusinessCategories = [];
      _businessRegistrationFile = null;
      _gstCertificateFile = null;
      _panCardFile = null;
      _professionalLicenseFile = null;
      // additional docs cleared above
      _businessRegistrationFileName = null;
      _gstCertificateFileName = null;
      _panCardFileName = null;
      _professionalLicenseFileName = null;
      // additional docs cleared above
      _businessRegistrationUrl = null;
      _gstCertificateUrl = null;
      _panCardUrl = null;
      _professionalLicenseUrl = null;
      // additional docs cleared above
      _frontStoreImages = [];
      _frontStoreImageUrls = [];
      _storeLogo = null;
      _storeLogoUrl = null;
      _profileBanner = null;
      _profileBannerUrl = null;
      _signatureController.clear();
      _signerNameController.clear();
      _signatureBytes = null;
      _signatureImageUrl = null;
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
          aadhaarNumberController: _aadhaarNumberController,
          residentialAddressController: _residentialAddressController,
          aadhaarFrontImage: _aadhaarFrontImage,
          aadhaarBackImage: _aadhaarBackImage,
          aadhaarFrontImageUrl: _aadhaarFrontImageUrl,
          aadhaarBackImageUrl: _aadhaarBackImageUrl,
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
          selectedIdProofType: _selectedIdProofType,
          onIdProofTypeChanged: (value) {
            setState(() => _selectedIdProofType = value);
          },
          vendorDetails: widget
              .vendorDetails, // Pass vendor details for rejection highlighting
          isAadhaarFrontReuploaded: _aadhaarFrontReuploaded,
          isAadhaarBackReuploaded: _aadhaarBackReuploaded,
          onAadhaarFrontReuploaded: () {
            setState(() {
              _aadhaarFrontReuploaded = true;
            });
          },
          onAadhaarBackReuploaded: () {
            setState(() {
              _aadhaarBackReuploaded = true;
            });
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
          onLocationSelected: (lat, lng) {
            setState(() {
              _businessLatitude = lat;
              _businessLongitude = lng;
            });
          },
          initialLatitude: _businessLatitude,
          initialLongitude: _businessLongitude,
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
          businessRegistrationUrl: _businessRegistrationUrl,
          gstCertificateFile: _gstCertificateFile,
          gstCertificateUrl: _gstCertificateUrl,
          panCardFile: _panCardFile,
          panCardUrl: _panCardUrl,
          professionalLicenseFile: _professionalLicenseFile,
          professionalLicenseUrl: _professionalLicenseUrl,
          businessRegistrationFileName: _businessRegistrationFileName,
          gstCertificateFileName: _gstCertificateFileName,
          panCardFileName: _panCardFileName,
          professionalLicenseFileName: _professionalLicenseFileName,

          // Dynamic Additional Documents parameters
          additionalDocuments: _additionalDocuments,
          onAddDocument: _addAdditionalDocument,
          onRemoveDocument: _removeAdditionalDocument,
          onDocumentFileSelected: _onAdditionalDocumentFileSelected,

          panCardNumberController: _panCardNumberController,
          gstCertificateNumberController: _gstCertificateNumberController,
          businessRegistrationNumberController:
              _businessRegistrationNumberController,
          professionalLicenseNumberController:
              _professionalLicenseNumberController,

          panCardExpiryDateController: _panCardExpiryDateController,
          gstExpiryDateController: _gstExpiryDateController,
          businessRegistrationExpiryDateController:
              _businessRegistrationExpiryDateController,
          professionalLicenseExpiryDateController:
              _professionalLicenseExpiryDateController,

          enabled: enabled,
          onFileSelected: _onFileSelected,
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(3, isValid),
            );
          },
          vendorDetails: widget
              .vendorDetails, // Pass vendor details for rejection highlighting
          reuploadedDocuments: _documentsReuploaded,
          onDocumentReuploaded: (key) {
            setState(() {
              _documentsReuploaded[key] = true;
            });
          },
        );
      case 4:
        return PhotosSection(
          frontStoreImages: _frontStoreImages,
          frontStoreImageUrls: _frontStoreImageUrls,
          storeLogo: _storeLogo,
          storeLogoUrl: _storeLogoUrl,
          profileBanner: _profileBanner,
          profileBannerUrl: _profileBannerUrl,
          enabled: enabled,
          onFrontStoreImagesChanged: (images) {
            setState(() {
              _frontStoreImages = images;
            });
          },
          onFrontStoreImageUrlsChanged: (urls) {
            setState(() {
              _frontStoreImageUrls = urls;
            });
          },
          onStoreLogoChanged: (file) {
            setState(() {
              _storeLogo = file;
            });
          },
          onProfileBannerChanged: (file) {
            setState(() {
              _profileBanner = file;
            });
          },
          onValidationChanged: (isValid) {
            // Store Photos Validation
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
          signatureImageUrl: _signatureImageUrl,
          acceptedTerms: _acceptedTerms,
          enabled: enabled,
          onSignatureSaved: (bytes) => setState(() {
            _signatureBytes = bytes;
            // Also clear the image URL when clearing signature for re-upload
            if (bytes == null) {
              _signatureImageUrl = null;
            }
          }),
          onTermsChanged: (value) => setState(() => _acceptedTerms = value),
          onValidationChanged: (isValid) {
            context.read<VendorStepperBloc>().add(
              VendorStepperSectionValidated(5, isValid),
            );
          },
          onConsentChanged: (value) => setState(() => _consentAccepted = value),
          onPricingAgreementChanged: (value) =>
              setState(() => _pricingAgreementAccepted = value),
          onSlvAgreementChanged: (value) =>
              setState(() => _slvAgreementAccepted = value),
          consentAccepted: _consentAccepted,
          pricingAgreementAccepted: _pricingAgreementAccepted,
          slvAgreementAccepted: _slvAgreementAccepted,
          vendorDetails: widget
              .vendorDetails, // Pass vendor details for rejection highlighting
          isSignatureReuploaded: _signatureReuploaded,
          onSignatureReuploaded: () {
            setState(() {
              _signatureReuploaded = true;
            });
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
                        Text(
                          state.message, // Use dynamic message from state
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
