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
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
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
import 'widgets/animated_section_container.dart';
import 'widgets/section_header.dart';
import 'widgets/stepper_navigation_buttons.dart';

class VendorProfileScreen extends StatefulWidget {
  final UserEntity user;

  const VendorProfileScreen({super.key, required this.user});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());
  List<bool>? _previousExpandedState;

  // Controllers - Personal Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _residentialAddressController = TextEditingController();
  File? _aadhaarPhoto;

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
    _fetchCategories();
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

  @override
  void dispose() {
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
    super.dispose();
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
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
    final categoryIds = _selectedBusinessCategories
        .map((name) => _categoryNameToId[name] ?? name)
        .where((id) => id.isNotEmpty)
        .toList();

    final vendor = VendorEntity(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      mobile: _phoneController.text,
      businessName: _businessNameController.text,
      businessEmail: _businessEmailController.text,
      altMobile: _altBusinessMobileController.text,
      address: _businessAddressController.text,
      categories: categoryIds,
      bussinessmobile: _businessMobileController.text,
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
      _aadhaarPhoto = null;
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
          aadhaarPhoto: _aadhaarPhoto,
          enabled: enabled,
          onAadhaarPhotoChanged: (photo) {
            setState(() => _aadhaarPhoto = photo);
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
    return BlocListener<VendorFormBloc, VendorFormState>(
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetForm();
                          Navigator.of(context).pop();
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
      child: BlocConsumer<VendorStepperBloc, VendorStepperState>(
        listenWhen: (previous, current) {
          // Only listen when expanded state actually changes
          return previous.sectionExpanded != current.sectionExpanded;
        },
        listener: (context, state) {
          // Only scroll if a section was newly expanded
          if (_previousExpandedState != null) {
            for (int i = 0; i < state.sectionExpanded.length; i++) {
              if (state.sectionExpanded[i] && !_previousExpandedState![i]) {
                _scrollToSection(i);
                break;
              }
            }
          }
          _previousExpandedState = List.from(state.sectionExpanded);
        },
        builder: (context, stepperState) {
          return BlocBuilder<VendorFormBloc, VendorFormState>(
            builder: (context, formState) {
              final isSubmitting = formState is VendorFormSubmitting;

              return Scaffold(
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
                                    !isSubmitting,
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
                      isSubmitting: isSubmitting,
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
