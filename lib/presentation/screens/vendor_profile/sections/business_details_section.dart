import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/multi_select_dropdown.dart';

class BusinessDetailsSection extends StatefulWidget {
  final TextEditingController businessNameController;
  final TextEditingController businessLegalNameController;
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
    required this.businessLegalNameController,
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
  String? _businessLegalNameError;
  String? _businessEmailError;
  String? _businessMobileError;
  String? _altBusinessMobileError;
  String? _businessCategoryError;
  String? _businessAddressError;
  bool _showErrors = false;

  // Google Places State
  Timer? _debounce;
  double? _latitude;
  double? _longitude;
  static const String _googleApiKey = 'AIzaSyBAgjZGzhUBDznc-wI5eGRHyjVTfENnLSs';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    widget.businessNameController.addListener(_validate);
    widget.businessLegalNameController.addListener(_validate);
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
    final businessLegalNameError = Validators.validateRequired(
      widget.businessLegalNameController.text,
      'Business Legal Name',
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
    final businessAddressError = Validators.validateAddress(
      widget.businessAddressController.text,
    );

    final isValid =
        businessNameError == null &&
        businessLegalNameError == null &&
        businessEmailError == null &&
        businessMobileError == null &&
        altBusinessMobileError == null &&
        businessCategoryError == null &&
        businessAddressError == null &&
        widget.businessNameController.text.isNotEmpty &&
        widget.businessLegalNameController.text.isNotEmpty &&
        widget.businessEmailController.text.isNotEmpty &&
        widget.businessMobileController.text.isNotEmpty &&
        widget.selectedCategories.isNotEmpty &&
        widget.businessAddressController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _businessNameError = businessNameError;
        _businessLegalNameError = businessLegalNameError;
        _businessEmailError = businessEmailError;
        _businessMobileError = businessMobileError;
        _altBusinessMobileError = altBusinessMobileError;
        _businessCategoryError = businessCategoryError;
        _businessAddressError = businessAddressError;
      });
    }
  }

 

 

  Future<List<PlaceSuggestion>> _getPlaceSuggestions(String query) async {
    if (query.isEmpty) return [];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': _googleApiKey,
        // 'components': 'country:in', // Optional: Restrict to India
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
    return [];
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
          'place_id': placeId,
          'key': _googleApiKey,
          'fields': 'formatted_address,geometry',
        });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final formattedAddress = result['formatted_address'] as String?;
          final geometry = result['geometry'];
          final location = geometry?['location'];

          if (formattedAddress != null) {
            widget.businessAddressController.text = formattedAddress;
            // Trigger validtion logic
            if (!_showErrors) setState(() => _showErrors = true);
            _validate();
          }

          if (location != null) {
            setState(() {
              _latitude = location['lat'];
              _longitude = location['lng'];
            });

            // Note: Since backend submission logic is handled by parent/bloc,
            // valid coordinates are currently stored in local state.
            // If the backend requires them, they can be exposed via a new callback
            // or by updating an entity passed to this widget.
            debugPrint('Selected Location: $_latitude, $_longitude');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch place details')),
      );
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
          label: 'Business Display Name *',
          hint: 'e.g., Alpha Enterprises',
          errorText: _businessNameError,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: widget.businessLegalNameController,
          label: 'Business Legal Name *',
          hint: 'e.g., Alpha Enterprises Pvt. Ltd.',
          errorText: _businessLegalNameError,
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Allow backspace / clear
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }

                    // Block first digit if it is 0–5
                    if (newValue.text.length == 1) {
                      final firstDigit = int.tryParse(newValue.text);
                      if (firstDigit != null && firstDigit < 6) {
                        return oldValue;
                      }
                    }

                    return newValue;
                  }),
                ],
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Allow backspace / clear
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }

                    // Block first digit if it is 0–5
                    if (newValue.text.length == 1) {
                      final firstDigit = int.tryParse(newValue.text);
                      if (firstDigit != null && firstDigit < 6) {
                        return oldValue;
                      }
                    }

                    return newValue;
                  }),
                ],
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
        // Business Address with Location Fetch
        _buildBusinessAddressField(),
      ],
    );
  }

  Widget _buildBusinessAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field 1: Google Places Search
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Address *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<PlaceSuggestion>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<PlaceSuggestion>.empty();
                    }
                    return await _getPlaceSuggestions(textEditingValue.text);
                  },
                  displayStringForOption: (PlaceSuggestion option) =>
                      option.description,
                  onSelected: (PlaceSuggestion selection) {
                    _getPlaceDetails(selection.placeId);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search address with Google Maps…',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: widget.enabled
                                ? Colors.white
                                : AppColors.background,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.search,
                              color: AppColors.textHint,
                            ),
                          ),
                          enabled: widget.enabled,
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<PlaceSuggestion> onSelected,
                        Iterable<PlaceSuggestion> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: constraints.maxWidth,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final PlaceSuggestion option = options
                                      .elementAt(index);
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    title: Text(
                                      option.description,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Field 2: Editable Address
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Business Address (Editable) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.businessAddressController,
              enabled: widget.enabled,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Address will be auto-filled from Google Maps or enter manually',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                errorText: _businessAddressError,
                filled: true,
                fillColor: widget.enabled ? Colors.white : AppColors.background,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
              onChanged: (_) {
                if (!_showErrors) setState(() => _showErrors = true);
              },
            ),
            const SizedBox(height: 6),
            Text(
              'You can edit it as needed.',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Maps Coordinates:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lat: $_latitude, Lng: $_longitude',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
    );
  }
}
