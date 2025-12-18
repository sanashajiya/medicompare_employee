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
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController aadhaarNumberController;
  final TextEditingController residentialAddressController;
  final File? aadhaarFrontImage;
  final File? aadhaarBackImage;
  final bool enabled;
  final Function(File?) onAadhaarFrontImageChanged;
  final Function(File?) onAadhaarBackImageChanged;
  final Function(bool isValid) onValidationChanged;

  const PersonalDetailsSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.aadhaarNumberController,
    required this.residentialAddressController,
    required this.aadhaarFrontImage,
    required this.aadhaarBackImage,
    required this.enabled,
    required this.onAadhaarFrontImageChanged,
    required this.onAadhaarBackImageChanged,
    required this.onValidationChanged,
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
  String? _passwordError;
  String? _confirmPasswordError;
  String? _aadhaarNumberError;
  String? _aadhaarFrontImageError;
  String? _aadhaarBackImageError;
  String? _residentialAddressError;
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
    widget.aadhaarNumberController.addListener(_validate);
    widget.residentialAddressController.addListener(_validate);
  }

  @override
  void didUpdateWidget(PersonalDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aadhaarFrontImage != widget.aadhaarFrontImage ||
        oldWidget.aadhaarBackImage != widget.aadhaarBackImage) {
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
    final passwordError = Validators.validatePassword(
      widget.passwordController.text,
    );
    final confirmPasswordError = Validators.validateConfirmPassword(
      widget.passwordController.text,
      widget.confirmPasswordController.text,
    );
    final aadhaarNumberError = Validators.validateAadhaarNumber(
      widget.aadhaarNumberController.text,
    );
    final aadhaarFrontImageError = widget.aadhaarFrontImage == null
        ? 'Aadhaar front image is required'
        : null;
    final aadhaarBackImageError = widget.aadhaarBackImage == null
        ? 'Aadhaar back image is required'
        : null;
    final residentialAddressError = Validators.validateAddress(
      widget.residentialAddressController.text,
    );

    final isValid =
        firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        aadhaarNumberError == null &&
        aadhaarFrontImageError == null &&
        aadhaarBackImageError == null &&
        residentialAddressError == null &&
        widget.firstNameController.text.isNotEmpty &&
        widget.lastNameController.text.isNotEmpty &&
        widget.emailController.text.isNotEmpty &&
        widget.phoneController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty &&
        widget.confirmPasswordController.text.isNotEmpty &&
        widget.aadhaarNumberController.text.isNotEmpty &&
        widget.aadhaarFrontImage != null &&
        widget.aadhaarBackImage != null &&
        widget.residentialAddressController.text.isNotEmpty;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _firstNameError = firstNameError;
        _lastNameError = lastNameError;
        _emailError = emailError;
        _phoneError = phoneError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
        _aadhaarNumberError = aadhaarNumberError;
        _aadhaarFrontImageError = aadhaarFrontImageError;
        _aadhaarBackImageError = aadhaarBackImageError;
        _residentialAddressError = residentialAddressError;
      });
    }
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
      if (!_showErrors) setState(() => _showErrors = true);
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
        const SizedBox(height: 20),
        // Aadhaar Number
        CustomTextField(
          controller: widget.aadhaarNumberController,
          label: 'Aadhaar Number *',
          hint: 'Enter 12 digit Aadhaar number',
          errorText: _aadhaarNumberError,
          keyboardType: TextInputType.number,
          maxLength: 12,
          enabled: widget.enabled,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        // Aadhaar Front Image Upload
        _buildAadhaarImageUpload(true),
        const SizedBox(height: 20),
        // Aadhaar Back Image Upload
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
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
      ],
    );
  }

  Widget _buildAadhaarImageUpload(bool isFront) {
    final image = isFront ? widget.aadhaarFrontImage : widget.aadhaarBackImage;
    final error = isFront ? _aadhaarFrontImageError : _aadhaarBackImageError;
    final label = isFront ? 'Aadhaar Front Image *' : 'Aadhaar Back Image *';
    final uploadText = isFront
        ? 'Upload Aadhaar Front Image'
        : 'Upload Aadhaar Back Image';

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
        if (image != null)
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
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle image loading errors gracefully
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: AppColors.error.withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image cannot be loaded',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please upload again',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
}
