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

  static const List<String> _bankOptions = [
    // Public Sector Banks
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
    // Private Sector Banks
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
    // Small Finance Banks
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
    // Payments Banks
    'Airtel Payments Bank',
    'India Post Payments Bank',
    'Fino Payments Bank',
    'Jio Payments Bank',
    'Paytm Payments Bank',
    'NSDL Payments Bank',
    'Aditya Birla Idea Payments Bank',
    // Foreign / International Banks
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
    // Other
    'Other (Please specify below)',
  ];

  String? _selectedBankName;

  @override
  void initState() {
    super.initState();
    _initializeSelectedBank();
    _addListeners();
  }

  void _initializeSelectedBank() {
    final currentBank = widget.bankNameController.text;
    if (currentBank.isNotEmpty) {
      if (_bankOptions.contains(currentBank)) {
        _selectedBankName = currentBank;
      } else {
        _selectedBankName = 'Other (Please specify below)';
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
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.toUpperCase(),
                selection: newValue.selection,
              );
            }),
          ],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Name *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showErrors && _bankNameError != null
                            ? AppColors.error
                            : AppColors.border,
                      ),
                      color: widget.enabled
                          ? Colors.white
                          : Colors.grey.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBankName,
                        hint: Text(
                          'Select Bank',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _bankOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: widget.enabled
                            ? (String? newValue) {
                                setState(() {
                                  _selectedBankName = newValue;
                                  if (newValue !=
                                      'Other (Please specify below)') {
                                    widget.bankNameController.text = newValue!;
                                  } else {
                                    widget.bankNameController.clear();
                                  }
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                  if (_showErrors && _bankNameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        _bankNameError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
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
        if (_selectedBankName == 'Other (Please specify below)') ...[
          const SizedBox(height: 20),
          CustomTextField(
            controller: widget.bankNameController,
            label: 'Enter Bank Name *',
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
        ],
      ],
    );
  }
}
