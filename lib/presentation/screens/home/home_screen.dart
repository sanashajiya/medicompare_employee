import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../blocs/employee_form/employee_form_bloc.dart';
import '../../blocs/employee_form/employee_form_event.dart';
import '../../blocs/employee_form/employee_form_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/file_upload_field.dart';
import '../../widgets/multi_select_dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // File Names
  String? _businessRegistrationFile;
  String? _gstCertificateFile;
  String? _panCardFile;
  String? _professionalLicenseFile;

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

  final List<String> _businessCategories = [
    'Medicines',
    'Surgeries',
    'Lab Tests',
    'Diagnostics',
    'Nursing Care',
    'Ambulance Service',
  ];

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
        _professionalLicenseFile != null;
  }

  void _onSubmit() {
    setState(() => _showErrors = true);
    _validateForm();

    if (_isFormValid()) {
      // Create employee entity with all data
      final employee = EmployeeEntity(
        name: '${_firstNameController.text} ${_lastNameController.text}',
        employeeId: DateTime.now().millisecondsSinceEpoch.toString(),
        department: _selectedBusinessCategories.join(', '),
        email: _emailController.text,
        mobileNumber: _phoneController.text,
        isMobileVerified: true,
      );

      context.read<EmployeeFormBloc>().add(EmployeeFormSubmitted(employee));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _pickFile(String fieldName) {
    // Simulate file picker (in real app, use file_picker package)
    setState(() {
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      switch (fieldName) {
        case 'business_registration':
          _businessRegistrationFile = fileName;
          break;
        case 'gst_certificate':
          _gstCertificateFile = fileName;
          break;
        case 'pan_card':
          _panCardFile = fileName;
          break;
        case 'professional_license':
          _professionalLicenseFile = fileName;
          break;
      }
    });
    _validateForm();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmployeeFormBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Vendor Profile'),
          automaticallyImplyLeading: false,
        ),
        body: BlocListener<EmployeeFormBloc, EmployeeFormState>(
          listener: (context, state) {
            if (state is EmployeeFormSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text('Success'),
                    ],
                  ),
                  content: const Text(
                    'Your vendor profile has been submitted successfully!',
                  ),
                  actions: [
                    CustomButton(
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
                          _showErrors = false;
                        });
                        context.read<EmployeeFormBloc>().add(
                          EmployeeFormReset(),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else if (state is EmployeeFormFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
            builder: (context, state) {
              final isSubmitting = state is EmployeeFormSubmitting;

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
                          items: _businessCategories,
                          enabled: !isSubmitting,
                          onChanged: (values) {
                            setState(() => _selectedBusinessCategories = values);
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
                          fileName: _businessRegistrationFile,
                          errorText: _businessRegistrationError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('business_registration'),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'GST Registration Certificate',
                          fileName: _gstCertificateFile,
                          errorText: _gstCertificateError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('gst_certificate'),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'PAN Card',
                          fileName: _panCardFile,
                          errorText: _panCardError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('pan_card'),
                        ),
                        const SizedBox(height: 20),
                        FileUploadField(
                          label: 'Professional License',
                          fileName: _professionalLicenseFile,
                          errorText: _professionalLicenseError,
                          required: true,
                          enabled: !isSubmitting,
                          onTap: () => _pickFile('professional_license'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

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
