import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/multi_select_dropdown.dart';

class BusinessDetailsSection extends StatefulWidget {
  final TextEditingController businessNameController;
  final TextEditingController businessEmailController;
  final TextEditingController businessMobileController;
  final TextEditingController altBusinessMobileController;
  final TextEditingController businessAddressController;
  final List<String> selectedCategories;
  final List<CategoryModel> availableCategories;
  final bool categoriesLoaded;
  final bool enabled;
  final Function(List<String>) onCategoriesChanged;
  final Function(bool isValid) onValidationChanged;

  const BusinessDetailsSection({
    super.key,
    required this.businessNameController,
    required this.businessEmailController,
    required this.businessMobileController,
    required this.altBusinessMobileController,
    required this.businessAddressController,
    required this.selectedCategories,
    required this.availableCategories,
    required this.categoriesLoaded,
    required this.enabled,
    required this.onCategoriesChanged,
    required this.onValidationChanged,
  });

  @override
  State<BusinessDetailsSection> createState() => _BusinessDetailsSectionState();
}

class _BusinessDetailsSectionState extends State<BusinessDetailsSection> {
  String? _businessNameError;
  String? _businessEmailError;
  String? _businessMobileError;
  String? _altBusinessMobileError;
  String? _businessCategoryError;
  String? _businessAddressError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    widget.businessNameController.addListener(_validate);
    widget.businessEmailController.addListener(_validate);
    widget.businessMobileController.addListener(_validate);
    widget.altBusinessMobileController.addListener(_validate);
    widget.businessAddressController.addListener(_validate);
  }

  void _validate() {
    final businessNameError = Validators.validateRequired(
      widget.businessNameController.text,
      'Business Name',
    );
    final businessEmailError = Validators.validateEmail(
      widget.businessEmailController.text,
    );
    final businessMobileError = Validators.validateMobileNumber(
      widget.businessMobileController.text,
    );
    final altBusinessMobileError = Validators.validateOptionalMobileNumber(
      widget.altBusinessMobileController.text,
    );
    final businessCategoryError = widget.selectedCategories.isEmpty
        ? 'Please select at least one business category'
        : null;
    final businessAddressError = Validators.validateRequired(
      widget.businessAddressController.text,
      'Business Address',
    );

    final isValid =
        businessNameError == null &&
        businessEmailError == null &&
        businessMobileError == null &&
        altBusinessMobileError == null &&
        businessCategoryError == null &&
        businessAddressError == null &&
        widget.businessNameController.text.isNotEmpty &&
        widget.businessEmailController.text.isNotEmpty &&
        widget.businessMobileController.text.isNotEmpty &&
        widget.selectedCategories.isNotEmpty &&
        widget.businessAddressController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _businessNameError = businessNameError;
        _businessEmailError = businessEmailError;
        _businessMobileError = businessMobileError;
        _altBusinessMobileError = altBusinessMobileError;
        _businessCategoryError = businessCategoryError;
        _businessAddressError = businessAddressError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your business information',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: widget.businessNameController,
          label: 'Business Name *',
          hint: 'e.g., Alpha Enterprises',
          errorText: _businessNameError,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.businessEmailController,
          label: 'Business Email *',
          hint: 'e.g., vendor@company.com',
          errorText: _businessEmailError,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.businessMobileController,
                label: 'Business Mobile *',
                hint: '10 digits',
                errorText: _businessMobileError,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: widget.enabled,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: widget.altBusinessMobileController,
                label: 'Alt Mobile (Optional)',
                hint: '10 digits',
                errorText: _altBusinessMobileError,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: widget.enabled,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        MultiSelectDropdown(
          label: 'Business Categories *',
          selectedValues: widget.selectedCategories,
          hint: 'Select your business categories',
          errorText: _showErrors ? _businessCategoryError : null,
          items: widget.availableCategories.map((cat) => cat.name).toList(),
          enabled: widget.enabled && widget.categoriesLoaded,
          onChanged: (values) {
            widget.onCategoriesChanged(values);
            if (!_showErrors) setState(() => _showErrors = true);
            _validate();
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.businessAddressController,
          label: 'Business Address *',
          hint: 'e.g., 123, Main Block, City, Dist, Country',
          errorText: _businessAddressError,
          maxLines: 3,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
      ],
    );
  }
}
