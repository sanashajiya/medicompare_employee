import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';

class BankingDetailsSection extends StatefulWidget {
  final TextEditingController accountNumberController;
  final TextEditingController confirmAccountNumberController;
  final TextEditingController accountHolderNameController;
  final TextEditingController ifscCodeController;
  final TextEditingController bankNameController;
  final TextEditingController bankBranchController;
  final bool enabled;
  final Function(bool isValid) onValidationChanged;

  const BankingDetailsSection({
    super.key,
    required this.accountNumberController,
    required this.confirmAccountNumberController,
    required this.accountHolderNameController,
    required this.ifscCodeController,
    required this.bankNameController,
    required this.bankBranchController,
    required this.enabled,
    required this.onValidationChanged,
  });

  @override
  State<BankingDetailsSection> createState() => _BankingDetailsSectionState();
}

class _BankingDetailsSectionState extends State<BankingDetailsSection> {
  String? _accountNumberError;
  String? _confirmAccountNumberError;
  String? _accountHolderNameError;
  String? _ifscCodeError;
  String? _bankNameError;
  String? _bankBranchError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    widget.accountNumberController.addListener(_validate);
    widget.confirmAccountNumberController.addListener(_validate);
    widget.accountHolderNameController.addListener(_validate);
    widget.ifscCodeController.addListener(_validate);
    widget.bankNameController.addListener(_validate);
    widget.bankBranchController.addListener(_validate);
  }

  void _validate() {
    final accountNumberError = Validators.validateAccountNumber(
      widget.accountNumberController.text,
    );
    final confirmAccountNumberError = Validators.validateConfirmAccountNumber(
      widget.accountNumberController.text,
      widget.confirmAccountNumberController.text,
    );
    final accountHolderNameError = Validators.validateAlphaOnly(
      widget.accountHolderNameController.text,
      'Account Holder Name',
    );
    final ifscCodeError = Validators.validateIfscCode(
      widget.ifscCodeController.text,
    );
    final bankNameError = Validators.validateAlphaOnly(
      widget.bankNameController.text,
      'Bank Name',
    );
    final bankBranchError = Validators.validateAlphaOnly(
      widget.bankBranchController.text,
      'Bank Branch',
    );

    final isValid =
        accountNumberError == null &&
        confirmAccountNumberError == null &&
        accountHolderNameError == null &&
        ifscCodeError == null &&
        bankNameError == null &&
        bankBranchError == null &&
        widget.accountNumberController.text.isNotEmpty &&
        widget.confirmAccountNumberController.text.isNotEmpty &&
        widget.accountHolderNameController.text.isNotEmpty &&
        widget.ifscCodeController.text.isNotEmpty &&
        widget.bankNameController.text.isNotEmpty &&
        widget.bankBranchController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _accountNumberError = accountNumberError;
        _confirmAccountNumberError = confirmAccountNumberError;
        _accountHolderNameError = accountHolderNameError;
        _ifscCodeError = ifscCodeError;
        _bankNameError = bankNameError;
        _bankBranchError = bankBranchError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your banking information',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: widget.accountNumberController,
          label: 'Account Number *',
          hint: 'e.g., 1234567890',
          errorText: _accountNumberError,
          keyboardType: TextInputType.number,
          enabled: widget.enabled,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.confirmAccountNumberController,
          label: 'Confirm Account Number *',
          hint: 'Re-enter account number',
          errorText: _confirmAccountNumberError,
          keyboardType: TextInputType.number,
          enabled: widget.enabled,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.accountHolderNameController,
          label: 'Account Holder Name *',
          hint: 'e.g., John Doe',
          errorText: _accountHolderNameError,
          enabled: widget.enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
          ],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.ifscCodeController,
          label: 'IFSC Code *',
          hint: 'e.g., SBIN0001234',
          errorText: _ifscCodeError,
          enabled: widget.enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toUpperCase());
            }),
          ],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.bankNameController,
                label: 'Bank Name *',
                hint: 'e.g., State Bank',
                errorText: _bankNameError,
                enabled: widget.enabled,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                ],
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: widget.bankBranchController,
                label: 'Bank Branch *',
                hint: 'e.g., Delhi',
                errorText: _bankBranchError,
                enabled: widget.enabled,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                ],
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
