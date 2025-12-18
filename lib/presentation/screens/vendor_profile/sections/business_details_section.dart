import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  bool _isFetchingLocation = false;

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

  Future<void> _fetchCurrentLocation() async {
    if (_isFetchingLocation) return;

    setState(() => _isFetchingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(
          'Location services are disabled. Please enable them in settings.',
        );
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError(
            'Location permission denied. Please grant permission to fetch address.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
          'Location permission permanently denied. Please enable it from app settings.',
          showSettingsButton: true,
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _formatAddress(place);
        widget.businessAddressController.text = address;
        if (!_showErrors) setState(() => _showErrors = true);
        _validate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Address fetched successfully')),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showLocationError(
        'Failed to fetch location. Please try again or enter manually.',
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }

    return parts.join(', ');
  }

  void _showLocationError(String message, {bool showSettingsButton = false}) {
    if (!mounted) return;

    setState(() => _isFetchingLocation = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_off, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: showSettingsButton
            ? SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              )
            : null,
      ),
    );
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
        // Business Address with Location Fetch
        _buildBusinessAddressField(),
      ],
    );
  }

  Widget _buildBusinessAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Business Address *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // Location fetch button
            InkWell(
              onTap: widget.enabled && !_isFetchingLocation
                  ? _fetchCurrentLocation
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isFetchingLocation)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Icon(
                        Icons.my_location,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      _isFetchingLocation ? 'Fetching...' : 'Use Current',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
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
            hintText: 'e.g., 123, Main Block, City, Dist, Country',
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
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: Align(
                alignment: Alignment.topRight,
                widthFactor: 1,
                heightFactor: 1,
                child: IconButton(
                  onPressed: widget.enabled && !_isFetchingLocation
                      ? _fetchCurrentLocation
                      : null,
                  icon: _isFetchingLocation
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                  tooltip: 'Fetch current location',
                ),
              ),
            ),
          ),
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 6),
        Text(
          'Tap the location icon to auto-fill your current address',
          style: TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

