import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
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

  bool _showErrors = false;
  bool _acceptedTerms = false;
  String? _termsError;

  // Category management
  List<CategoryModel> _availableCategories = [];
  Map<String, String> _categoryNameToId = {}; // name -> id mapping
  bool _categoriesLoaded = false;
  bool _categoriesLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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
      
      final categories = categoriesData
          .map((json) {
            print('📄 Parsing category: ${json['name']} (${json['_id']})');
            return CategoryModel.fromJson(json);
          })
          .toList();
      
      print('✅ Categories parsed successfully: ${categories.length} items');
      
      setState(() {
        _availableCategories = categories;
        _categoryNameToId = {
          for (var cat in categories) cat.name: cat.id
        };
        _categoriesLoaded = true;
        _categoriesLoading = false;
      });
      
      print('✅ Categories loaded and UI updated: ${categories.length}');
      for (var cat in categories) {
        print('   - ${cat.name} (${cat.id})');
      }
      
      // Verify dropdown will have items
      print('📋 Dropdown items: ${_availableCategories.map((c) => c.name).toList()}');
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
          ? Validators.validateRequired(
              _accountHolderNameController.text,
              'Account Holder Name',
            )
          : null;
      _ifscCodeError = _showErrors
          ? Validators.validateIfscCode(_ifscCodeController.text)
          : null;
      _bankNameError = _showErrors
          ? Validators.validateRequired(_bankNameController.text, 'Bank Name')
          : null;
      _bankBranchError = _showErrors
          ? Validators.validateRequired(
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
        _acceptedTerms;
  }

  void _onSubmit() {
    setState(() => _showErrors = true);
    _validateForm();

    if (_isFormValid()) {
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
        categories: _selectedBusinessCategories,
        bussinessmobile: _businessMobileController.text,
        docNames: [
          'PAN Card',
          'GST Certificate',
          'Business Registration',
          'Professional License',
        ],
        docIds: ['PAN', 'GST', 'BR', 'PL'],
        documentNumbers: [
          '',
          '',
          '',
          '',
        ], // Add document number fields if needed
        files: [
          _panCardFile,
          _gstCertificateFile,
          _businessRegistrationFile,
          _professionalLicenseFile,
        ],
        bankName: _bankNameController.text,
        accountName: _accountHolderNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
        branchName: _bankBranchController.text,
      );

      context.read<VendorFormBloc>().add(
        VendorFormSubmitted(vendor, widget.user.token),
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
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
      allowMultiple: false,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;

    if (platformFile.path == null) return;

    final file = File(platformFile.path!);

    // Extra safety: validate extension
    final extension = platformFile.extension?.toLowerCase();
    const allowedExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

    if (extension == null || !allowedExtensions.contains(extension)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Only PDF, Word, and Excel files are allowed',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      switch (fieldName) {
        case 'business_registration':
          _businessRegistrationFile = file;
          _businessRegistrationFileName = platformFile.name;
          break;

        case 'gst_certificate':
          _gstCertificateFile = file;
          _gstCertificateFileName = platformFile.name;
          break;

        case 'pan_card':
          _panCardFile = file;
          _panCardFileName = platformFile.name;
          break;

        case 'professional_license':
          _professionalLicenseFile = file;
          _professionalLicenseFileName = platformFile.name;
          break;
      }
    });

    _validateForm();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selected: ${platformFile.name}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } on PlatformException catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick file: ${e.message ?? "Unknown error"}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Vendor Profile'),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<VendorFormBloc, VendorFormState>(
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
                    horizontal: 24,
                    vertical: 32,
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
                      const Text(
                        'Vendor created successfully',
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
                              _acceptedTerms = false;
                              _showErrors = false;
                            });
                            context.read<VendorFormBloc>().add(VendorFormReset());
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Personal Details Section
                  _buildSectionCard(
                    context,
                    title: 'Personal Details',
                    icon: Icons.person_outline,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameController,
                              label: 'First Name *',
                              hint: 'Enter first name',
                              errorText: _firstNameError,
                              enabled: !isSubmitting,
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameController,
                              label: 'Last Name *',
                              hint: 'Enter last name',
                              errorText: _lastNameError,
                              enabled: !isSubmitting,
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                        ],
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
                        label: 'Business Name *',
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
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      MultiSelectDropdown(
                        label: 'Business Categories *',
                        selectedValues: _selectedBusinessCategories,
                        hint: 'Select your business categories',
                        errorText: _businessCategoryError,
                        items: _availableCategories.map((cat) => cat.name).toList(),
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
                        label: 'Account Holder Name *',
                        hint: 'e.g., John Doe',
                        errorText: _accountHolderNameError,
                        enabled: !isSubmitting,
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
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _bankNameController,
                              label: 'Bank Name *',
                              hint: 'e.g., State Bank of India',
                              errorText: _bankNameError,
                              enabled: !isSubmitting,
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _bankBranchController,
                              label: 'Bank Branch *',
                              hint: 'e.g., Delhi',
                              errorText: _bankBranchError,
                              enabled: !isSubmitting,
                              onChanged: (_) => _validateForm(),
                            ),
                          ),
                        ],
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
                      const SizedBox(height: 20),
                      FileUploadField(
                        label: 'GST Registration Certificate',
                        fileName: _gstCertificateFileName,
                        errorText: _gstCertificateError,
                        required: true,
                        enabled: !isSubmitting,
                        onTap: () => _pickFile('gst_certificate'),
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
                      const SizedBox(height: 20),
                      FileUploadField(
                        label: 'Professional License',
                        fileName: _professionalLicenseFileName,
                        errorText: _professionalLicenseError,
                        required: true,
                        enabled: !isSubmitting,
                        onTap: () => _pickFile('professional_license'),
                      ),
                    ],
                  ),
    
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
                                          text: 'I agree to the ',
                                        ),
                                        TextSpan(
                                          text: 'Terms and Conditions',
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
