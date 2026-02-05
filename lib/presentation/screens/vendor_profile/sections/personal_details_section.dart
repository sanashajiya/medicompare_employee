import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';

class PersonalDetailsSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aadhaarNumberController;
  final TextEditingController residentialAddressController;
  final File? aadhaarFrontImage;
  final File? aadhaarBackImage;
  final String? aadhaarFrontImageUrl;
  final String? aadhaarBackImageUrl;
  final bool enabled;
  final Function(File?) onAadhaarFrontImageChanged;
  final Function(File?) onAadhaarBackImageChanged;
  final Function(bool isValid) onValidationChanged;
  final String? selectedIdProofType;
  final Function(String?) onIdProofTypeChanged;

  const PersonalDetailsSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.aadhaarNumberController,
    required this.residentialAddressController,
    required this.aadhaarFrontImage,
    required this.aadhaarBackImage,
    this.aadhaarFrontImageUrl,
    this.aadhaarBackImageUrl,
    required this.enabled,
    required this.onAadhaarFrontImageChanged,
    required this.onAadhaarBackImageChanged,
    required this.onValidationChanged,
    required this.selectedIdProofType,
    required this.onIdProofTypeChanged,
  });

  @override
  State<PersonalDetailsSection> createState() => _PersonalDetailsSectionState();
}

class _PersonalDetailsSectionState extends State<PersonalDetailsSection> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _aadhaarNumberError;
  String? _aadhaarFrontImageError;
  String? _aadhaarBackImageError;
  String? _residentialAddressError;
  String? _idProofTypeError;
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
    widget.aadhaarNumberController.addListener(_validate);
    widget.residentialAddressController.addListener(_validate);
  }

  @override
  void didUpdateWidget(PersonalDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aadhaarFrontImage != widget.aadhaarFrontImage ||
        oldWidget.aadhaarBackImage != widget.aadhaarBackImage ||
        oldWidget.aadhaarFrontImageUrl != widget.aadhaarFrontImageUrl ||
        oldWidget.aadhaarBackImageUrl != widget.aadhaarBackImageUrl) {
      _validate();
    }
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

    // Validate ID Proof Number based on type
    String? aadhaarNumberError;
    final idProofNumber = widget.aadhaarNumberController.text;

    switch (widget.selectedIdProofType) {
      case 'Aadhar':
        aadhaarNumberError = Validators.validateAadhaarNumber(idProofNumber);
        break;
      case 'Passport':
        aadhaarNumberError = Validators.validatePassportNumber(idProofNumber);
        break;
      case 'PAN Card':
        aadhaarNumberError = Validators.validatePanCardNumber(idProofNumber);
        break;
      case 'Driving License':
        aadhaarNumberError = Validators.validateDrivingLicenseNumber(
          idProofNumber,
        );
        break;
      case 'Voter ID':
        aadhaarNumberError = Validators.validateVoterIdNumber(idProofNumber);
        break;
      default:
        aadhaarNumberError = Validators.validateRequired(
          idProofNumber,
          'ID Proof Number',
        );
    }

    final idProofTypeError = widget.selectedIdProofType == null
        ? 'ID Proof Type is mandatory'
        : null;

    // Validate image presence (File OR URL)
    final hasFrontImage =
        widget.aadhaarFrontImage != null ||
        (widget.aadhaarFrontImageUrl != null &&
            widget.aadhaarFrontImageUrl!.isNotEmpty);

    final hasBackImage =
        widget.aadhaarBackImage != null ||
        (widget.aadhaarBackImageUrl != null &&
            widget.aadhaarBackImageUrl!.isNotEmpty);

    final aadhaarFrontImageError = !hasFrontImage
        ? 'Id Proof Front Image is required'
        : null;

    final aadhaarBackImageError = !hasBackImage
        ? 'Id Proof Back Image is required'
        : null;

    final residentialAddressError = Validators.validateAddress(
      widget.residentialAddressController.text,
    );

    final isValid =
        firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null &&
        aadhaarNumberError == null &&
        idProofTypeError == null &&
        aadhaarFrontImageError == null &&
        aadhaarBackImageError == null &&
        residentialAddressError == null &&
        widget.firstNameController.text.isNotEmpty &&
        widget.lastNameController.text.isNotEmpty &&
        widget.emailController.text.isNotEmpty &&
        widget.phoneController.text.isNotEmpty &&
        widget.aadhaarNumberController.text.isNotEmpty &&
        widget.selectedIdProofType != null &&
        hasFrontImage &&
        hasBackImage &&
        widget.residentialAddressController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors && mounted) {
      setState(() {
        _firstNameError = firstNameError;
        _lastNameError = lastNameError;
        _emailError = emailError;
        _phoneError = phoneError;
        _aadhaarNumberError = aadhaarNumberError;
        _idProofTypeError = idProofTypeError;
        _aadhaarFrontImageError = aadhaarFrontImageError;
        _aadhaarBackImageError = aadhaarBackImageError;
        _residentialAddressError = residentialAddressError;
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners to prevent setState after dispose
    widget.firstNameController.removeListener(_validate);
    widget.lastNameController.removeListener(_validate);
    widget.emailController.removeListener(_validate);
    widget.phoneController.removeListener(_validate);
    widget.aadhaarNumberController.removeListener(_validate);
    widget.residentialAddressController.removeListener(_validate);
    super.dispose();
  }

  Future<void> _pickAadhaarImage(ImageSource source, bool isFront) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      const int maxSizeMB = 5;
      const int maxSizeBytes = maxSizeMB * 1024 * 1024;

      if (file.lengthSync() > maxSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image must be less than $maxSizeMB MB'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (isFront) {
        widget.onAadhaarFrontImageChanged(file);
      } else {
        widget.onAadhaarBackImageChanged(file);
      }
      if (!_showErrors && mounted) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _showImagePickerBottomSheet(bool isFront) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Aadhaar ${isFront ? "Front" : "Back"} Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to capture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAadhaarImage(ImageSource.camera, isFront);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from device'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAadhaarImage(ImageSource.gallery, isFront);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAadhaarImage(bool isFront) {
    if (isFront) {
      widget.onAadhaarFrontImageChanged(null);
    } else {
      widget.onAadhaarBackImageChanged(null);
    }
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
                  if (!_showErrors && mounted)
                    setState(() => _showErrors = true);
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
                  if (!_showErrors && mounted)
                    setState(() => _showErrors = true);
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
            if (!_showErrors && mounted) setState(() => _showErrors = true);
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
            if (!_showErrors && mounted) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        // ID Proof Type Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID Proof Type *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showErrors && _idProofTypeError != null
                      ? AppColors.error
                      : AppColors.border,
                ),
                color: widget.enabled ? Colors.white : Colors.grey.shade100,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.selectedIdProofType,
                  hint: Text(
                    'Select ID Proof Type',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items:
                      [
                        'Aadhar',
                        'Passport',
                        'Driving License',
                        'Voter ID',
                        'PAN Card',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: widget.enabled
                      ? (String? newValue) {
                          widget.onIdProofTypeChanged(newValue);
                          // Create a dummy mismatch check to trigger revalidation
                          if (!_showErrors && mounted)
                            setState(() => _showErrors = true);
                        }
                      : null,
                ),
              ),
            ),
            if (_showErrors && _idProofTypeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  _idProofTypeError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        // ID Proof Number
        CustomTextField(
          controller: widget.aadhaarNumberController,
          label: 'ID Proof Number *',
          hint: 'Enter ID Proof Number',
          errorText: _aadhaarNumberError,
          keyboardType: widget.selectedIdProofType == 'Aadhar'
              ? TextInputType.number
              : TextInputType.text,
          maxLength: _getIdProofMaxLength(widget.selectedIdProofType),
          enabled: widget.enabled,

          inputFormatters: [
            if (widget.selectedIdProofType == 'Aadhar')
              FilteringTextInputFormatter.digitsOnly,
            if (widget.selectedIdProofType != 'Aadhar')
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            if (widget.selectedIdProofType == 'PAN Card')
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(text: newValue.text.toUpperCase());
              }),
          ],
          onChanged: (_) {
            if (!_showErrors && mounted) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        // Id Proof Image Upload
        _buildAadhaarImageUpload(true),
        const SizedBox(height: 20),
        // Govt Id Proof Back Image Upload
        _buildAadhaarImageUpload(false),
        const SizedBox(height: 20),
        // Residential Address
        CustomTextField(
          controller: widget.residentialAddressController,
          label: 'Residential Address *',
          hint: 'Enter your complete residential address',
          errorText: _residentialAddressError,
          maxLines: 3,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors && mounted) setState(() => _showErrors = true);
          },
        ),
      ],
    );
  }

  Widget _buildAadhaarImageUpload(bool isFront) {
    final imageFile = isFront
        ? widget.aadhaarFrontImage
        : widget.aadhaarBackImage;
    final imageUrl = isFront
        ? widget.aadhaarFrontImageUrl
        : widget.aadhaarBackImageUrl;
    final error = isFront ? _aadhaarFrontImageError : _aadhaarBackImageError;
    final label = isFront ? 'Id Proof Front Image *' : 'Id Proof Back Image *';
    final uploadText = isFront
        ? 'Upload Id Proof Front Image'
        : 'Upload Id Proof Back Image';

    final hasImage =
        imageFile != null || (imageUrl != null && imageUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (hasImage)
          // Photo Preview
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  child: imageFile != null
                      ? Image.file(
                          imageFile,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorPlaceholder(),
                        )
                      : Image.network(
                          imageUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorPlaceholder(),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${isFront ? "Front" : "Back"} image uploaded',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.enabled
                            ? () => _showImagePickerBottomSheet(isFront)
                            : null,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Replace'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.enabled
                            ? () => _removeAadhaarImage(isFront)
                            : null,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          // Upload Button
          InkWell(
            onTap: widget.enabled
                ? () => _showImagePickerBottomSheet(isFront)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showErrors && error != null
                      ? AppColors.error
                      : AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    uploadText,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Take photo or choose from gallery',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_showErrors && error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      color: AppColors.error.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: AppColors.error, size: 48),
          const SizedBox(height: 8),
          Text(
            'Image cannot be loaded',
            style: TextStyle(color: AppColors.error, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Please upload again',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  int _getIdProofMaxLength(String? type) {
    switch (type) {
      case 'Aadhar':
        return 12;
      case 'Passport':
        return 8;
      case 'PAN Card':
        return 10;
      case 'Driving License':
        return 16;
      case 'Voter ID':
        return 10;
      default:
        return 20;
    }
  }
}
