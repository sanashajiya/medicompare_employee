import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/file_upload_field.dart';

class DocumentsSection extends StatefulWidget {
  final File? businessRegistrationFile;
  final File? gstCertificateFile;
  final File? panCardFile;
  final File? professionalLicenseFile;
  final File? additionalDocumentFile;
  final String? businessRegistrationFileName;
  final String? gstCertificateFileName;
  final String? panCardFileName;
  final String? professionalLicenseFileName;
  final String? additionalDocumentFileName;
  final TextEditingController panCardNumberController;
  final TextEditingController gstCertificateNumberController;
  final TextEditingController businessRegistrationNumberController;
  final TextEditingController professionalLicenseNumberController;
  final TextEditingController additionalDocumentNameController;
  final bool enabled;
  final Function(String fieldName, File? file, String? fileName) onFileSelected;
  final Function(bool isValid) onValidationChanged;

  const DocumentsSection({
    super.key,
    required this.businessRegistrationFile,
    required this.gstCertificateFile,
    required this.panCardFile,
    required this.professionalLicenseFile,
    required this.additionalDocumentFile,
    required this.businessRegistrationFileName,
    required this.gstCertificateFileName,
    required this.panCardFileName,
    required this.professionalLicenseFileName,
    required this.additionalDocumentFileName,
    required this.panCardNumberController,
    required this.gstCertificateNumberController,
    required this.businessRegistrationNumberController,
    required this.professionalLicenseNumberController,
    required this.additionalDocumentNameController,
    required this.enabled,
    required this.onFileSelected,
    required this.onValidationChanged,
  });

  @override
  State<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _businessRegistrationError;
  String? _gstCertificateError;
  String? _panCardError;
  String? _professionalLicenseError;
  String? _additionalDocumentError;
  bool _showErrors = false;

  static const int _maxFileSizeMB = 5;
  static const int _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    widget.additionalDocumentNameController.addListener(_validate);
    _validate();
  }

  @override
  void dispose() {
    widget.additionalDocumentNameController.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final businessRegistrationError = Validators.validateFileUpload(
      widget.businessRegistrationFile,
      'Business Registration Certificate',
    );
    final gstCertificateError = Validators.validateFileUpload(
      widget.gstCertificateFile,
      'GST Registration Certificate',
    );
    final panCardError = Validators.validateFileUpload(
      widget.panCardFile,
      'PAN Card',
    );
    final professionalLicenseError = Validators.validateFileUpload(
      widget.professionalLicenseFile,
      'Professional License',
    );

    // Additional document validation: if name is entered, file is required
    String? additionalDocumentError;
    final hasAdditionalName = widget.additionalDocumentNameController.text
        .trim()
        .isNotEmpty;
    if (hasAdditionalName && widget.additionalDocumentFile == null) {
      additionalDocumentError = 'Please upload the additional document';
    }

    final isValid =
        businessRegistrationError == null &&
        gstCertificateError == null &&
        panCardError == null &&
        professionalLicenseError == null &&
        additionalDocumentError == null &&
        widget.businessRegistrationFile != null &&
        widget.gstCertificateFile != null &&
        widget.panCardFile != null &&
        widget.professionalLicenseFile != null;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _businessRegistrationError = businessRegistrationError;
        _gstCertificateError = gstCertificateError;
        _panCardError = panCardError;
        _professionalLicenseError = professionalLicenseError;
        _additionalDocumentError = additionalDocumentError;
      });
    }
  }

  void _showUploadOptions(String fieldName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
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
              const SizedBox(height: 20),
              Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to upload',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromCamera(fieldName);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        color: AppColors.success,
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromGallery(fieldName);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'PDF',
                        color: AppColors.error,
                        onTap: () {
                          Navigator.pop(context);
                          _pickPdfFile(fieldName);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(String fieldName) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileName = pickedFile.name;

      if (!_validateFile(file, fileName, fieldName)) return;

      widget.onFileSelected(fieldName, file, fileName);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to capture image');
    }
  }

  Future<void> _pickFromGallery(String fieldName) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileName = pickedFile.name;

      if (!_validateFile(file, fileName, fieldName)) return;

      widget.onFileSelected(fieldName, file, fileName);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick image');
    }
  }

  Future<void> _pickPdfFile(String fieldName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      final file = File(platformFile.path!);
      final fileName = platformFile.name;

      if (!_validateFile(file, fileName, fieldName)) return;

      widget.onFileSelected(fieldName, file, fileName);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick PDF');
    }
  }

  bool _validateFile(File file, String fileName, String fieldName) {
    // Check extension
    final ext = fileName.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      _setFieldError(fieldName, 'Unsupported format. Use PDF, JPG, or PNG');
      return false;
    }

    // Check size
    if (file.lengthSync() > _maxFileSizeBytes) {
      _setFieldError(fieldName, 'File must be less than $_maxFileSizeMB MB');
      return false;
    }

    return true;
  }

  void _setFieldError(String fieldName, String error) {
    setState(() {
      _showErrors = true;
      switch (fieldName) {
        case 'business_registration':
          _businessRegistrationError = error;
          break;
        case 'gst_certificate':
          _gstCertificateError = error;
          break;
        case 'pan_card':
          _panCardError = error;
          break;
        case 'professional_license':
          _professionalLicenseError = error;
          break;
        case 'additional_document':
          _additionalDocumentError = error;
          break;
      }
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _removeFile(String fieldName) {
    widget.onFileSelected(fieldName, null, null);
    _validate();
  }

  @override
  void didUpdateWidget(DocumentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    final hasAdditionalName = widget.additionalDocumentNameController.text
        .trim()
        .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload required documents',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        FileUploadField(
          label: 'Business Registration Certificate',
          fileName: widget.businessRegistrationFileName,
          file: widget.businessRegistrationFile,
          errorText: _showErrors ? _businessRegistrationError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _showUploadOptions('business_registration'),
          onRemove: () => _removeFile('business_registration'),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.businessRegistrationNumberController,
          label: 'Business Registration Number',
          hint: 'Enter registration number',
          enabled: widget.enabled,
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'GST Registration Certificate',
          fileName: widget.gstCertificateFileName,
          file: widget.gstCertificateFile,
          errorText: _showErrors ? _gstCertificateError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _showUploadOptions('gst_certificate'),
          onRemove: () => _removeFile('gst_certificate'),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.gstCertificateNumberController,
          label: 'GST Certificate Number',
          hint: 'Enter GST number',
          enabled: widget.enabled,
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'PAN Card',
          fileName: widget.panCardFileName,
          file: widget.panCardFile,
          errorText: _showErrors ? _panCardError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _showUploadOptions('pan_card'),
          onRemove: () => _removeFile('pan_card'),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.panCardNumberController,
          label: 'PAN Card Number',
          hint: 'Enter PAN number (e.g., ABCDE1234F)',
          enabled: widget.enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toUpperCase());
            }),
          ],
        ),
        const SizedBox(height: 20),
        FileUploadField(
          label: 'Professional License',
          fileName: widget.professionalLicenseFileName,
          file: widget.professionalLicenseFile,
          errorText: _showErrors ? _professionalLicenseError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _showUploadOptions('professional_license'),
          onRemove: () => _removeFile('professional_license'),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.professionalLicenseNumberController,
          label: 'Professional License Number',
          hint: 'Enter license number',
          enabled: widget.enabled,
        ),
        // Additional Document Section
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Additional Document (Optional)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Add any other supporting document if needed',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.additionalDocumentNameController,
                label: 'Document Name',
                hint: 'e.g., Trade License, FSSAI Certificate',
                enabled: widget.enabled,
                onChanged: (_) {
                  if (!_showErrors) setState(() => _showErrors = true);
                },
              ),
              const SizedBox(height: 16),
              FileUploadField(
                label: 'Upload Document',
                fileName: widget.additionalDocumentFileName,
                file: widget.additionalDocumentFile,
                errorText: _showErrors ? _additionalDocumentError : null,
                required: hasAdditionalName,
                enabled: widget.enabled,
                onTap: () => _showUploadOptions('additional_document'),
                onRemove: () => _removeFile('additional_document'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

