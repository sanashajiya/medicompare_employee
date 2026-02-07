import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/local/auth_local_storage.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vendor_entity.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../../blocs/vendor_form/vendor_form_event.dart';
import '../../blocs/vendor_form/vendor_form_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/file_upload_field.dart';
import '../../widgets/multi_select_dropdown.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserEntity user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Personal Details Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Business Details Controllers
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessMobileController = TextEditingController();
  final _altBusinessMobileController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Banking Information Controllers
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();

  // Multi-select Values
  List<String> _selectedBusinessCategories = [];

  // File objects and names
  File? _businessRegistrationFile;
  File? _gstCertificateFile;
  File? _panCardFile;
  File? _professionalLicenseFile;

  String? _businessRegistrationFileName;
  String? _gstCertificateFileName;
  String? _panCardFileName;
  String? _professionalLicenseFileName;

  // Signature
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  Uint8List? _signatureBytes;
  String? _signatureError;

  // Error States
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _businessNameError;
  String? _businessEmailError;
  String? _businessMobileError;
  String? _altBusinessMobileError;
  String? _businessCategoryError;
  String? _businessAddressError;

  String? _accountNumberError;
  String? _confirmAccountNumberError;
  String? _accountHolderNameError;
  String? _ifscCodeError;
  String? _bankNameError;
  String? _bankBranchError;

  String? _businessRegistrationError;
  String? _gstCertificateError;
  String? _panCardError;
  String? _professionalLicenseError;

  // Document Number Controllers
  final _panCardNumberController = TextEditingController();
  final _gstCertificateNumberController = TextEditingController();
  final _businessRegistrationNumberController = TextEditingController();
  final _professionalLicenseNumberController = TextEditingController();

  bool _showErrors = false;
  bool _acceptedTerms = false;
  String? _termsError;

  // Category management
  List<CategoryModel> _availableCategories = [];
  final List<File> _frontendImages = [];
  final List<File> _backendImages = [];

  String? _frontendImagesError;
  String? _backendImagesError;

  Map<String, String> _categoryNameToId = {}; // name -> id mapping
  bool _categoriesLoaded = false;
  bool _categoriesLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear login status from SharedPreferences
      final authStorage = sl<AuthLocalStorage>();
      await authStorage.clearLoginStatus();

      // Navigate to login screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _fetchCategories() async {
    if (_categoriesLoading) return;

    setState(() => _categoriesLoading = true);

    try {
      print('🔄 Fetching categories from: ${ApiEndpoints.getCategories}');

      final apiService = ApiService();
      final categoriesData = await apiService.getCategories(
        ApiEndpoints.getCategories,
      );

      print('📦 Raw categories data received: ${categoriesData.length} items');

      final categories = categoriesData.map((json) {
        print('📄 Parsing category: ${json['name']} (${json['_id']})');
        return CategoryModel.fromJson(json);
      }).toList();

      print('✅ Categories parsed successfully: ${categories.length} items');

      setState(() {
        _availableCategories = categories;
        _categoryNameToId = {for (var cat in categories) cat.name: cat.id};
        _categoriesLoaded = true;
        _categoriesLoading = false;
      });

      print('✅ Categories loaded and UI updated: ${categories.length}');
      for (var cat in categories) {
        print('   - ${cat.name} (${cat.id})');
      }

      // Verify dropdown will have items
      print(
        '📋 Dropdown items: ${_availableCategories.map((c) => c.name).toList()}',
      );
    } catch (e) {
      print('❌ Error fetching categories: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      setState(() {
        _categoriesLoaded = true;
        _categoriesLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _businessNameController.dispose();
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
    _signatureController.dispose();
    _panCardNumberController.dispose();
    _gstCertificateNumberController.dispose();
    _businessRegistrationNumberController.dispose();
    _professionalLicenseNumberController.dispose();

    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Personal Details Validation
      _firstNameError = _showErrors
          ? Validators.validateRequired(_firstNameController.text, 'First Name')
          : null;
      _lastNameError = _showErrors
          ? Validators.validateRequired(_lastNameController.text, 'Last Name')
          : null;
      _emailError = _showErrors
          ? Validators.validateEmail(_emailController.text)
          : null;
      _phoneError = _showErrors
          ? Validators.validateMobileNumber(_phoneController.text)
          : null;
      _passwordError = _showErrors
          ? Validators.validatePassword(_passwordController.text)
          : null;
      _confirmPasswordError = _showErrors
          ? Validators.validateConfirmPassword(
              _passwordController.text,
              _confirmPasswordController.text,
            )
          : null;
      _frontendImagesError = _showErrors && _frontendImages.isEmpty
          ? 'Please upload at least one frontend image'
          : null;

      _backendImagesError = _showErrors && _backendImages.isEmpty
          ? 'Please upload at least one backend image'
          : null;

      // Business Details Validation
      _businessNameError = _showErrors
          ? Validators.validateRequired(
              _businessNameController.text,
              'Business Name',
            )
          : null;
      _businessEmailError = _showErrors
          ? Validators.validateEmail(_businessEmailController.text)
          : null;
      _businessMobileError = _showErrors
          ? Validators.validateMobileNumber(_businessMobileController.text)
          : null;
      _altBusinessMobileError = _showErrors
          ? Validators.validateOptionalMobileNumber(
              _altBusinessMobileController.text,
            )
          : null;
      _businessCategoryError =
          _showErrors && _selectedBusinessCategories.isEmpty
          ? 'Please select at least one business category'
          : null;
      _businessAddressError = _showErrors
          ? Validators.validateRequired(
              _businessAddressController.text,
              'Business Address',
            )
          : null;

      // Banking Information Validation
      _accountNumberError = _showErrors
          ? Validators.validateAccountNumber(_accountNumberController.text)
          : null;
      _confirmAccountNumberError = _showErrors
          ? Validators.validateConfirmAccountNumber(
              _accountNumberController.text,
              _confirmAccountNumberController.text,
            )
          : null;
      _accountHolderNameError = _showErrors
          ? Validators.validateAlphaOnly(
              _accountHolderNameController.text,
              'Account Holder Name',
            )
          : null;
      _ifscCodeError = _showErrors
          ? Validators.validateIfscCode(_ifscCodeController.text)
          : null;
      _bankNameError = _showErrors
          ? Validators.validateAlphaOnly(_bankNameController.text, 'Bank Name')
          : null;
      _bankBranchError = _showErrors
          ? Validators.validateAlphaOnly(
              _bankBranchController.text,
              'Bank Branch',
            )
          : null;

      // Documents Validation
      _businessRegistrationError = _showErrors
          ? Validators.validateFileUpload(
              _businessRegistrationFile,
              'Business Registration Certificate',
            )
          : null;
      _gstCertificateError = _showErrors
          ? Validators.validateFileUpload(
              _gstCertificateFile,
              'GST Registration Certificate',
            )
          : null;
      _panCardError = _showErrors
          ? Validators.validateFileUpload(_panCardFile, 'PAN Card')
          : null;
      _professionalLicenseError = _showErrors
          ? Validators.validateFileUpload(
              _professionalLicenseFile,
              'Professional License',
            )
          : null;

      // Signature validation
      _signatureError = _showErrors && _signatureBytes == null
          ? 'Please provide your digital signature'
          : null;

      // Terms and Conditions Validation
      _termsError = _showErrors && !_acceptedTerms
          ? 'You must accept the Terms and Conditions'
          : null;
    });
  }

  bool _isFormValid() {
    return _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _businessNameError == null &&
        _businessEmailError == null &&
        _businessMobileError == null &&
        _altBusinessMobileError == null &&
        _businessCategoryError == null &&
        _businessAddressError == null &&
        _accountNumberError == null &&
        _confirmAccountNumberError == null &&
        _accountHolderNameError == null &&
        _ifscCodeError == null &&
        _bankNameError == null &&
        _bankBranchError == null &&
        _businessRegistrationError == null &&
        _gstCertificateError == null &&
        _panCardError == null &&
        _professionalLicenseError == null &&
        _termsError == null &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _businessNameController.text.isNotEmpty &&
        _businessEmailController.text.isNotEmpty &&
        _businessMobileController.text.isNotEmpty &&
        _selectedBusinessCategories.isNotEmpty &&
        _businessAddressController.text.isNotEmpty &&
        _accountNumberController.text.isNotEmpty &&
        _confirmAccountNumberController.text.isNotEmpty &&
        _accountHolderNameController.text.isNotEmpty &&
        _ifscCodeController.text.isNotEmpty &&
        _bankNameController.text.isNotEmpty &&
        _bankBranchController.text.isNotEmpty &&
        _businessRegistrationFile != null &&
        _gstCertificateFile != null &&
        _panCardFile != null &&
        _professionalLicenseFile != null &&
        _frontendImages.isNotEmpty &&
        _backendImages.isNotEmpty &&
        _signatureBytes != null &&
        _acceptedTerms;
  }

  Future<void> _pickImages({required bool isFrontend}) async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85, // compress slightly
      );

      if (pickedImages.isEmpty) return;

      const int maxImages = 30;
      const int maxSizeMB = 3;
      const int maxSizeBytes = maxSizeMB * 1024 * 1024;

      final List<File> currentImages = isFrontend
          ? _frontendImages
          : _backendImages;

      List<File> validImages = [];

      for (final xFile in pickedImages) {
        final file = File(xFile.path);

        if (file.lengthSync() > maxSizeBytes) {
          setState(() {
            if (isFrontend) {
              _frontendImagesError =
                  'Each image must be less than $maxSizeMB MB';
            } else {
              _backendImagesError =
                  'Each image must be less than $maxSizeMB MB';
            }
          });
          return;
        }

        if (currentImages.length + validImages.length >= maxImages) {
          setState(() {
            if (isFrontend) {
              _frontendImagesError = 'Maximum $maxImages images allowed';
            } else {
              _backendImagesError = 'Maximum $maxImages images allowed';
            }
          });
          return;
        }

        validImages.add(file);
      }

      setState(() {
        if (isFrontend) {
          _frontendImages.addAll(validImages);
          _frontendImagesError = null;
        } else {
          _backendImages.addAll(validImages);
          _backendImagesError = null;
        }
      });
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeImage(bool isFrontend, int index) {
    setState(() {
      if (isFrontend) {
        if (index >= 0 && index < _frontendImages.length) {
          _frontendImages.removeAt(index);
          if (_frontendImages.isEmpty) {
            _frontendImagesError = null;
          }
        }
      } else {
        if (index >= 0 && index < _backendImages.length) {
          _backendImages.removeAt(index);
          if (_backendImages.isEmpty) {
            _backendImagesError = null;
          }
        }
      }
    });
  }

  Future<void> _onSubmit() async {
    setState(() => _showErrors = true);
    _validateForm();

    if (_isFormValid()) {
      // Convert category names to IDs
      final categoryIds = _selectedBusinessCategories
          .map((name) => _categoryNameToId[name] ?? name)
          .where((id) => id.isNotEmpty)
          .toList();

      // Create vendor entity with all data
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
        expiryDates: ['', '', '', ''],
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

      // Get the BLoC reference before any async operations
      final bloc = context.read<VendorFormBloc>();

      print(
        '\n═══════════════════════════════════════════════════════════════',
      );
      print('🎯 FORM SUBMISSION STARTED');
      print('═══════════════════════════════════════════════════════════════');
      print('Frontend Images Selected: ${_frontendImages.length}');
      for (var i = 0; i < _frontendImages.length; i++) {
        print('  [$i] ${_frontendImages[i].path}');
      }
      print('Backend Images Selected: ${_backendImages.length}');
      for (var i = 0; i < _backendImages.length; i++) {
        print('  [$i] ${_backendImages[i].path}');
      }
      print(
        'Signature Bytes: ${_signatureBytes != null ? '${_signatureBytes!.length} bytes' : 'NULL'}',
      );

      // Convert signature bytes to File object if signature was collected
      List<File> signatureFiles = [];
      if (_signatureBytes != null) {
        try {
          // Use application documents directory instead of temp
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

          print('\n✍️  Signature File Created:');
          print('   Path: ${signatureFile.path}');
          print('   Size: ${_signatureBytes!.length} bytes');
          print('   Exists: ${await signatureFile.exists()}');

          signatureFiles.add(signatureFile);
        } catch (e) {
          print('❌ Error creating signature file: $e');
        }
      } else {
        print('⚠️  No signature bytes collected');
      }

      print('\n📤 Dispatching BLoC event with:');
      print('   Front Images: ${_frontendImages.length}');
      print('   Back Images: ${_backendImages.length}');
      print('   signature: ${signatureFiles.length}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      bloc.add(
        VendorFormSubmitted(
          vendor,
          widget.user.token,
          frontimages: _frontendImages,
          backimages: _backendImages,
          signature: signatureFiles,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickFile(String fieldName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      final file = File(platformFile.path!);

      // 🔹 Allowed extensions check
      final extension = platformFile.extension?.toLowerCase();
      const allowedExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

      if (extension == null || !allowedExtensions.contains(extension)) {
        return;
      }

      // FILE SIZE VALIDATION (5 MB)
      const int maxFileSizeMB = 5;
      const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

      if (file.lengthSync() > maxFileSizeBytes) {
        setState(() {
          switch (fieldName) {
            case 'business_registration':
              _businessRegistrationFile = null;
              _businessRegistrationFileName = null;
              _businessRegistrationError =
                  'Business Registration Certificate must be less than $maxFileSizeMB MB';
              break;

            case 'gst_certificate':
              _gstCertificateFile = null;
              _gstCertificateFileName = null;
              _gstCertificateError =
                  'GST Registration Certificate must be less than $maxFileSizeMB MB';
              break;

            case 'pan_card':
              _panCardFile = null;
              _panCardFileName = null;
              _panCardError = 'PAN Card must be less than $maxFileSizeMB MB';
              break;

            case 'professional_license':
              _professionalLicenseFile = null;
              _professionalLicenseFileName = null;
              _professionalLicenseError =
                  'Professional License must be less than $maxFileSizeMB MB';
              break;
          }
        });
        return; // ⛔ stop here
      }

      // ✅ VALID FILE — SAVE IT
      setState(() {
        switch (fieldName) {
          case 'business_registration':
            _businessRegistrationFile = file;
            _businessRegistrationFileName = platformFile.name;
            _businessRegistrationError = null;
            break;

          case 'gst_certificate':
            _gstCertificateFile = file;
            _gstCertificateFileName = platformFile.name;
            _gstCertificateError = null;
            break;

          case 'pan_card':
            _panCardFile = file;
            _panCardFileName = platformFile.name;
            _panCardError = null;
            break;

          case 'professional_license':
            _professionalLicenseFile = file;
            _professionalLicenseFileName = platformFile.name;
            _professionalLicenseError = null;
            break;
        }
      });

      _validateForm();
    } on PlatformException catch (_) {
      // silently fail (no snackbar spam)
    } catch (_) {
      // silently fail
    }
  }

  Widget _buildsignatureection() {
    return _buildSectionCard(
      context,
      title: 'Digital Signature',
      icon: Icons.draw_outlined,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Signature(
            controller: _signatureController,
            backgroundColor: Colors.grey[100]!,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _signatureController.clear();
                  setState(() {
                    _signatureBytes = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_signatureController.isNotEmpty) {
                    final bytes = await _signatureController.toPngBytes();
                    setState(() {
                      _signatureBytes = bytes;
                      _signatureError = null;
                    });
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        if (_signatureError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _signatureError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Complete Your Vendor Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: BlocListener<VendorFormBloc, VendorFormState>(
          listener: (context, state) {
            if (state is VendorFormSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success Icon with background
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
                        // Success Title
                        const Text(
                          'Success!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Success Message
                        Text(
                          state.message, // Use dynamic message from state
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // OK Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'OK',
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Reset form
                              setState(() {
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                _phoneController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                                _businessNameController.clear();
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
                                _selectedBusinessCategories = [];
                                _businessRegistrationFile = null;
                                _gstCertificateFile = null;
                                _panCardFile = null;
                                _professionalLicenseFile = null;
                                _businessRegistrationFileName = null;
                                _gstCertificateFileName = null;
                                _panCardFileName = null;
                                _professionalLicenseFileName = null;
                                _panCardNumberController.clear();
                                _gstCertificateNumberController.clear();
                                _businessRegistrationNumberController.clear();
                                _professionalLicenseNumberController.clear();
                                _frontendImages.clear();
                                _backendImages.clear();
                                _frontendImagesError = null;
                                _backendImagesError = null;
                                _signatureController.clear();
                                _signatureBytes = null;
                                _signatureError = null;
                                _acceptedTerms = false;
                                _showErrors = false;
                              });
                              context.read<VendorFormBloc>().add(
                                VendorFormReset(),
                              );
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
          child: BlocBuilder<VendorFormBloc, VendorFormState>(
            builder: (context, state) {
              final isSubmitting = state is VendorFormSubmitting;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + systemBottomPadding + (bottomInset > 0 ? 16 : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Details Section
                    _buildSectionCard(
                      context,
                      title: 'Personal Details',
                      icon: Icons.person_outline,
                      children: [
                        responsiveRow(
                          context: context,
                          left: CustomTextField(
                            controller: _firstNameController,
                            label: 'First Name *',
                            hint: 'Enter first name',
                            errorText: _firstNameError,
                            enabled: !isSubmitting,
                            onChanged: (_) => _validateForm(),
                          ),

                          right: CustomTextField(
                            controller: _lastNameController,
                            label: 'Last Name *',
                            hint: 'Enter last name',
                            errorText: _lastNameError,
                            enabled: !isSubmitting,
                            onChanged: (_) => _validateForm(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address *',
                          hint: 'Enter email address',
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number *',
                          hint: '10 digit mobile number',
                          errorText: _phoneError,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password *',
                          hint: 'Enter password',
                          errorText: _passwordError,
                          obscureText: true,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password *',
                          hint: 'Re-enter password',
                          errorText: _confirmPasswordError,
                          obscureText: true,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Business Details Section
                    _buildSectionCard(
                      context,
                      title: 'Business Details',
                      icon: Icons.business_outlined,
                      children: [
                        CustomTextField(
                          controller: _businessNameController,
                          label: 'Business Display Name *',
                          hint: 'e.g., Alpha Enterprises',
                          errorText: _businessNameError,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _businessEmailController,
                                label: 'Business Email *',
                                hint: 'e.g., vendor@company.com',
                                errorText: _businessEmailError,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isSubmitting,
                                onChanged: (_) => _validateForm(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        responsiveRow(
                          context: context,
                          left: CustomTextField(
                            controller: _businessMobileController,
                            label: 'Business Mobile Number *',
                            hint: '10 digits',
                            errorText: _businessMobileError,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            enabled: !isSubmitting,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) => _validateForm(),
                          ),

                          right: CustomTextField(
                            controller: _altBusinessMobileController,
                            label: 'Alternate Mobile (Optional)',
                            hint: '10 digits',
                            errorText: _altBusinessMobileError,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            enabled: !isSubmitting,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) => _validateForm(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MultiSelectDropdown(
                          label: 'Business Categories *',
                          selectedValues: _selectedBusinessCategories,
                          hint: 'Select your business categories',
                          errorText: _businessCategoryError,
                          items: _availableCategories
                              .map((cat) => cat.name)
                              .toList(),
                          enabled: !isSubmitting && _categoriesLoaded,
                          onChanged: (values) {
                            setState(
                              () => _selectedBusinessCategories = values,
                            );
                            _validateForm();
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _businessAddressController,
                          label: 'Business Address *',
                          hint: 'e.g., 123, Main Block, City, Dist, Country',
                          errorText: _businessAddressError,
                          maxLines: 3,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Banking Information Section
                    _buildSectionCard(
                      context,
                      title: 'Banking Information',
                      icon: Icons.account_balance_outlined,
                      children: [
                        CustomTextField(
                          controller: _accountNumberController,
                          label: 'Account Number *',
                          hint: 'e.g., 1234567890',
                          errorText: _accountNumberError,
                          keyboardType: TextInputType.number,
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _confirmAccountNumberController,
                          label: 'Confirm Account Number *',
                          hint: 'Re-enter account number',
                          errorText: _confirmAccountNumberError,
                          keyboardType: TextInputType.number,
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _accountHolderNameController,
                          label: 'Account  Name *',
                          hint: 'e.g., John Doe',
                          errorText: _accountHolderNameError,
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z ]'),
                            ),
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _ifscCodeController,
                          label: 'IFSC Code *',
                          hint: 'e.g., SBIN0001234',
                          errorText: _ifscCodeError,
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]'),
                            ),
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              return newValue.copyWith(
                                text: newValue.text.toUpperCase(),
                              );
                            }),
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        responsiveRow(
                          context: context,

                          left: CustomTextField(
                            controller: _bankNameController,
                            label: 'Bank Name *',
                            hint: 'e.g., State Bank of India',
                            errorText: _bankNameError,
                            enabled: !isSubmitting,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z ]'),
                              ),
                            ],
                            onChanged: (_) => _validateForm(),
                          ),

                          right: CustomTextField(
                            controller: _bankBranchController,
                            label: 'Bank Branch *',
                            hint: 'e.g., Delhi',
                            errorText: _bankBranchError,
                            enabled: !isSubmitting,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z ]'),
                              ),
                            ],
                            onChanged: (_) => _validateForm(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Documents & Certifications Section
                    _buildSectionCard(
                      context,
                      title: 'Documents & Certifications',
                      icon: Icons.description_outlined,
                      children: [
                        FileUploadField(
                          label: 'Business Registration Certificate',
                          fileName: _businessRegistrationFileName,
                          errorText: _businessRegistrationError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('business_registration'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _businessRegistrationNumberController,
                          label: 'Business Registration Number',
                          hint: 'Enter registration number',
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'GST Registration Certificate',
                          fileName: _gstCertificateFileName,
                          errorText: _gstCertificateError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('gst_certificate'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _gstCertificateNumberController,
                          label: 'GST Certificate Number',
                          hint: 'Enter GST number',
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'PAN Card',
                          fileName: _panCardFileName,
                          errorText: _panCardError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('pan_card'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _panCardNumberController,
                          label: 'PAN Card Number',
                          hint: 'Enter PAN number (e.g., ABCDE1234F)',
                          enabled: !isSubmitting,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]'),
                            ),
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              return newValue.copyWith(
                                text: newValue.text.toUpperCase(),
                              );
                            }),
                          ],
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'Professional License',
                          fileName: _professionalLicenseFileName,
                          errorText: _professionalLicenseError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('professional_license'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _professionalLicenseNumberController,
                          label: 'Professional License Number',
                          hint: 'Enter license number',
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionCard(
                      context,
                      title: 'Photos',
                      icon: Icons.photo_library_outlined,
                      children: [
                        // Frontend Images Section
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 4,
                              ),
                            ),
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.browser_updated_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Frontend Images',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'UI/UX screenshots and designs',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Select Frontend Images',
                                icon: Icons.add_photo_alternate_rounded,
                                onPressed: () => _pickImages(isFrontend: true),
                                width: double.infinity,
                              ),
                              if (_frontendImagesError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _frontendImagesError!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (_frontendImages.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildImagePreviewGrid(
                                  _frontendImages,
                                  (index) => _removeImage(true, index),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Backend Images Section
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.secondary,
                                width: 4,
                              ),
                            ),
                            color: AppColors.secondary.withOpacity(0.05),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storage_rounded,
                                    color: AppColors.secondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Backend Images',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.secondary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Infrastructure and architecture',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Select Backend Images',
                                icon: Icons.add_photo_alternate_rounded,
                                onPressed: () => _pickImages(isFrontend: false),
                                width: double.infinity,
                              ),
                              if (_backendImagesError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _backendImagesError!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (_backendImages.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildImagePreviewGrid(
                                  _backendImages,
                                  (index) => _removeImage(false, index),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildsignatureection(),

                    const SizedBox(height: 24),

                    // Terms and Conditions Checkbox
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _acceptedTerms = value ?? false;
                                          });
                                          _validateForm();
                                        },
                                  activeColor: AppColors.primary,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                        children: [
                                          const TextSpan(
                                            text: 'Vendor agree to the ',
                                          ),
                                          TextSpan(
                                            text: 'SLA, Terms and Conditions',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_termsError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 48,
                                  top: 4,
                                ),
                                child: Text(
                                  _termsError!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      text: 'Submit Vendor Profile',
                      onPressed: !isSubmitting ? _onSubmit : null,
                      isLoading: isSubmitting,
                      width: double.infinity,
                      icon: Icons.send,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _buildImagePreviewGrid(List<File> images, Function(int) onRemoveImage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${images.length} image(s) selected',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            images.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index < images.length - 1 ? 12 : 0,
              ),
              child: _buildImageThumbnail(
                images[index],
                index,
                () => onRemoveImage(index),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildImageThumbnail(File imageFile, int index, VoidCallback onRemove) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // Image Container
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.border,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
      ),
      // Remove Button
      Positioned(
        top: -6,
        right: -6,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ),
      ),
    ],
  );
}

Widget responsiveRow({
  required BuildContext context,
  required Widget left,
  required Widget right,
}) {
  final width = MediaQuery.of(context).size.width;

  if (width < 380) {
    return Column(children: [left, const SizedBox(height: 16), right]);
  }

  return Row(
    children: [
      Expanded(child: left),
      const SizedBox(width: 16),
      Expanded(child: right),
    ],
  );
}
