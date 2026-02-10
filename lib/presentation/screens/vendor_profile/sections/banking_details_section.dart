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

  String? _selectedBank;
  static const String _otherBankOption = 'Other (Please specify below)';

  static const List<String> _bankOptions = [
    'State Bank of India',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'Bank of India',
    'Indian Bank',
    'Central Bank of India',
    'Indian Overseas Bank',
    'UCO Bank',
    'Bank of Maharashtra',
    'Punjab & Sind Bank',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Yes Bank',
    'IndusInd Bank',
    'RBL Bank',
    'Federal Bank',
    'IDFC First Bank',
    'Bandhan Bank',
    'Karur Vysya Bank',
    'South Indian Bank',
    'DCB Bank',
    'Dhanlaxmi Bank',
    'Tamilnad Mercantile Bank',
    'Karnataka Bank',
    'Catholic Syrian Bank',
    'AU Small Finance Bank',
    'Jana Small Finance Bank',
    'North East Small Finance Bank',
    'Shivalik Small Finance Bank',
    'Unity Small Finance Bank',
    'Suryoday Small Finance Bank',
    'Ujjivan Small Finance Bank',
    'Equitas Small Finance Bank',
    'ESAF Small Finance Bank',
    'Fincare Small Finance Bank',
    'Airtel Payments Bank',
    'India Post Payments Bank',
    'Fino Payments Bank',
    'Jio Payments Bank',
    'Paytm Payments Bank',
    'NSDL Payments Bank',
    'Aditya Birla Idea Payments Bank',
    'Standard Chartered Bank',
    'Citibank',
    'HSBC Bank',
    'Deutsche Bank',
    'DBS Bank',
    'BNP Paribas',
    'Barclays Bank',
    'Bank of America',
    'MUFG Bank',
    'ABN AMRO Bank',
    _otherBankOption,
  ];

  @override
  void initState() {
    super.initState();
    _initializeSelectedBank();
    _addListeners();

    // Auto-validate prefilled data in edit/resume mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validate();
    });
  }

  void _initializeSelectedBank() {
    final currentBankName = widget.bankNameController.text.trim();
    if (currentBankName.isNotEmpty) {
      if (_bankOptions.contains(currentBankName)) {
        _selectedBank = currentBankName;
      } else {
        _selectedBank = _otherBankOption;
      }
    }
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

    // Bank Name Validation
    String? bankNameError;
    if (_selectedBank == null) {
      bankNameError = 'Bank Name is required';
    } else if (_selectedBank == _otherBankOption) {
      if (widget.bankNameController.text.trim().isEmpty) {
        bankNameError = 'Please specify the bank name';
      }
    } else {
      // If a standard bank is selected, we assume it's valid.
      // Double check controller sync just in case
      if (widget.bankNameController.text != _selectedBank) {
        // Should ideally not happen if logic is correct, but safe to ignore or force sync
      }
    }

    // Existing validator was validateAlphaOnly, which we removed for Dropdown logic
    // But for Manual Input (Other), we might want to check for weird chars?
    // User requirement: "Stored correctly... Sent as string".
    // Let's assume emptiness check is sufficient for "Other" text field.

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
        widget.bankBranchController.text.isNotEmpty &&
        (_selectedBank != null &&
            (_selectedBank != _otherBankOption ||
                widget.bankNameController.text.isNotEmpty));

    widget.onValidationChanged(isValid);

    if (_showErrors && mounted) {
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
  void dispose() {
    // Remove listeners to prevent setState after dispose
    widget.accountNumberController.removeListener(_validate);
    widget.confirmAccountNumberController.removeListener(_validate);
    widget.accountHolderNameController.removeListener(_validate);
    widget.ifscCodeController.removeListener(_validate);
    widget.bankNameController.removeListener(_validate);
    widget.bankBranchController.removeListener(_validate);
    super.dispose();
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
            if (!_showErrors && mounted) setState(() => _showErrors = true);
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
            if (!_showErrors && mounted) setState(() => _showErrors = true);
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
            if (!_showErrors && mounted) setState(() => _showErrors = true);
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
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.toUpperCase(),
                selection: newValue.selection,
              );
            }),
          ],
          onChanged: (_) {
            if (!_showErrors && mounted) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),

        // Bank Name Dropdown
        DropdownButtonFormField<String>(
          value: _selectedBank,
          decoration: InputDecoration(
            labelText: 'Bank Name *',
            hintText: 'Select Bank',
            errorText: _bankNameError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: _bankOptions.map((bank) {
            return DropdownMenuItem<String>(value: bank, child: Text(bank));
          }).toList(),
          onChanged: widget.enabled
              ? (value) {
                  setState(() {
                    _selectedBank = value;
                    if (value != _otherBankOption) {
                      widget.bankNameController.text = value ?? '';
                    } else {
                      // Clear text if "Other" is selected to force user input
                      // But if switching back to "Other" from a known bank, we want it empty.
                      // If we already had a custom value, keeps it? No, simpler to clear or handle carefully.
                      // User requirement: "If Other... Show additional text input field... This field becomes mandatory"
                      // I'll clear it to ensure they type what they want.
                      if (_bankOptions.contains(
                        widget.bankNameController.text,
                      )) {
                        widget.bankNameController.clear();
                      }
                    }
                    _showErrors = true;
                  });
                  _validate();
                }
              : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a bank';
            }
            return null;
          },
        ),

        // Manual Bank Name Input (if "Other" is selected)
        if (_selectedBank == _otherBankOption) ...[
          const SizedBox(height: 20),
          CustomTextField(
            controller: widget.bankNameController,
            label: 'Enter Bank Name *',
            hint: 'e.g., My Local Co-op Bank',
            errorText:
                _bankNameError == 'Please specify the bank name' ||
                    (_bankNameError != null &&
                        _bankNameError!.contains('required'))
                ? _bankNameError
                : null,
            enabled: widget.enabled,
            onChanged: (_) {
              if (!_showErrors && mounted) setState(() => _showErrors = true);
            },
          ),
        ],

        const SizedBox(height: 20),

        CustomTextField(
          controller: widget.bankBranchController,
          label: 'Bank Branch *',
          hint: 'e.g., Delhi',
          errorText: _bankBranchError,
          enabled: widget.enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
          ],
          onChanged: (_) {
            if (!_showErrors && mounted) setState(() => _showErrors = true);
          },
        ),
      ],
    );
  }
}
