import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';

class PersonalDetailsSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;
  final Function(bool isValid) onValidationChanged;

  const PersonalDetailsSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.enabled,
    required this.onValidationChanged,
  });

  @override
  State<PersonalDetailsSection> createState() => _PersonalDetailsSectionState();
}

class _PersonalDetailsSectionState extends State<PersonalDetailsSection> {
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    widget.firstNameController.addListener(_validate);
    widget.lastNameController.addListener(_validate);
    widget.emailController.addListener(_validate);
    widget.phoneController.addListener(_validate);
    widget.passwordController.addListener(_validate);
    widget.confirmPasswordController.addListener(_validate);
  }

  void _validate() {
    final firstNameError = Validators.validateRequired(
      widget.firstNameController.text,
      'First Name',
    );
    final lastNameError = Validators.validateRequired(
      widget.lastNameController.text,
      'Last Name',
    );
    final emailError = Validators.validateEmail(widget.emailController.text);
    final phoneError = Validators.validateMobileNumber(
      widget.phoneController.text,
    );
    final passwordError = Validators.validatePassword(
      widget.passwordController.text,
    );
    final confirmPasswordError = Validators.validateConfirmPassword(
      widget.passwordController.text,
      widget.confirmPasswordController.text,
    );

    final isValid =
        firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        widget.firstNameController.text.isNotEmpty &&
        widget.lastNameController.text.isNotEmpty &&
        widget.emailController.text.isNotEmpty &&
        widget.phoneController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty &&
        widget.confirmPasswordController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _firstNameError = firstNameError;
        _lastNameError = lastNameError;
        _emailError = emailError;
        _phoneError = phoneError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
    }
  }

  void showValidationErrors() {
    setState(() => _showErrors = true);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your personal information',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.firstNameController,
                label: 'First Name *',
                hint: 'Enter first name',
                errorText: _firstNameError,
                enabled: widget.enabled,
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: widget.lastNameController,
                label: 'Last Name *',
                hint: 'Enter last name',
                errorText: _lastNameError,
                enabled: widget.enabled,
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.emailController,
          label: 'Email Address *',
          hint: 'Enter email address',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.phoneController,
          label: 'Phone Number *',
          hint: '10 digit mobile number',
          errorText: _phoneError,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          enabled: widget.enabled,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.passwordController,
          label: 'Password *',
          hint: 'Enter password',
          errorText: _passwordError,
          obscureText: true,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.confirmPasswordController,
          label: 'Confirm Password *',
          hint: 'Re-enter password',
          errorText: _confirmPasswordError,
          obscureText: true,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
      ],
    );
  }
}
