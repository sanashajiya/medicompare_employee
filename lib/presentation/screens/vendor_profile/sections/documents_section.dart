import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController businessRegistrationExpiryDateController;
  final TextEditingController gstExpiryDateController;
  final TextEditingController panCardExpiryDateController;
  final TextEditingController professionalLicenseExpiryDateController;
  final TextEditingController additionalDocumentExpiryDateController;
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
    required this.businessRegistrationExpiryDateController,
    required this.gstExpiryDateController,
    required this.panCardExpiryDateController,
    required this.professionalLicenseExpiryDateController,
    required this.additionalDocumentExpiryDateController,
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

  final FocusNode _businessRegistrationNumberFocus = FocusNode();
  final FocusNode _gstCertificateNumberFocus = FocusNode();
  final FocusNode _panCardNumberFocus = FocusNode();
  final FocusNode _professionalLicenseNumberFocus = FocusNode();
  final FocusNode _additionalDocumentNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Use FocusNodes for validation on blur
    _businessRegistrationNumberFocus.addListener(_onFocusChange);
    _gstCertificateNumberFocus.addListener(_onFocusChange);
    _panCardNumberFocus.addListener(_onFocusChange);
    _professionalLicenseNumberFocus.addListener(_onFocusChange);
    _additionalDocumentNameFocus.addListener(_onFocusChange);

    // Keep validation on date changes as they are picked via dialog
    widget.businessRegistrationExpiryDateController.addListener(_validate);
    widget.gstExpiryDateController.addListener(_validate);
    widget.panCardExpiryDateController.addListener(_validate);
    widget.professionalLicenseExpiryDateController.addListener(_validate);
    widget.additionalDocumentExpiryDateController.addListener(_validate);

    // Initial validation without showing errors
    widget.onValidationChanged(
      false,
    ); // Assume false initially or run full check logic without side effects

    // We can run _validate() but ensure _showErrors is false which it is by default
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _onFocusChange() {
    // Check if any controller has text, implying user interaction has started
    final hasInteraction =
        widget.businessRegistrationNumberController.text.isNotEmpty ||
        widget.gstCertificateNumberController.text.isNotEmpty ||
        widget.panCardNumberController.text.isNotEmpty ||
        widget.professionalLicenseNumberController.text.isNotEmpty ||
        widget.additionalDocumentNameController.text.isNotEmpty;

    if (hasInteraction && !_showErrors) {
      if (mounted) setState(() => _showErrors = true);
    }

    // Always validate on focus change to keep state in sync
    _validate();
  }

  @override
  void dispose() {
    widget.businessRegistrationExpiryDateController.removeListener(_validate);
    widget.gstExpiryDateController.removeListener(_validate);
    widget.panCardExpiryDateController.removeListener(_validate);
    widget.professionalLicenseExpiryDateController.removeListener(_validate);
    widget.additionalDocumentExpiryDateController.removeListener(_validate);

    _businessRegistrationNumberFocus.removeListener(_onFocusChange);
    _gstCertificateNumberFocus.removeListener(_onFocusChange);
    _panCardNumberFocus.removeListener(_onFocusChange);
    _professionalLicenseNumberFocus.removeListener(_onFocusChange);
    _additionalDocumentNameFocus.removeListener(_onFocusChange);

    _businessRegistrationNumberFocus.dispose();
    _gstCertificateNumberFocus.dispose();
    _panCardNumberFocus.dispose();
    _professionalLicenseNumberFocus.dispose();
    _additionalDocumentNameFocus.dispose();
    super.dispose();
  }

  bool? _lastIsValid;

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
        widget.professionalLicenseFile != null &&
        widget.businessRegistrationExpiryDateController.text.isNotEmpty &&
        widget.gstExpiryDateController.text.isNotEmpty &&
        widget.panCardExpiryDateController.text.isNotEmpty &&
        widget.professionalLicenseExpiryDateController.text.isNotEmpty;

    if (_lastIsValid != isValid) {
      _lastIsValid = isValid;
      // Defer callback to next frame to avoid build collisions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onValidationChanged(isValid);
      });
    }

    if (_showErrors) {
      // Only set state if something actually changed to avoid rebuilds
      if (_businessRegistrationError != businessRegistrationError ||
          _gstCertificateError != gstCertificateError ||
          _panCardError != panCardError ||
          _professionalLicenseError != professionalLicenseError ||
          _additionalDocumentError != additionalDocumentError) {
        setState(() {
          _businessRegistrationError = businessRegistrationError;
          _gstCertificateError = gstCertificateError;
          _panCardError = panCardError;
          _professionalLicenseError = professionalLicenseError;
          _additionalDocumentError = additionalDocumentError;
        });
      }
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

      if (!await _validateFileAsync(file, fileName, fieldName)) return;

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

      if (!await _validateFileAsync(file, fileName, fieldName)) return;

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

      if (!await _validateFileAsync(file, fileName, fieldName)) return;

      widget.onFileSelected(fieldName, file, fileName);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick PDF');
    }
  }

  Future<bool> _validateFileAsync(
    File file,
    String fileName,
    String fieldName,
  ) async {
    // Check extension
    final ext = fileName.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      _setFieldError(fieldName, 'Unsupported format. Use PDF, JPG, or PNG');
      return false;
    }

    // Check size - async to avoid blocking UI
    try {
      final len = await file.length();
      if (len > _maxFileSizeBytes) {
        _setFieldError(fieldName, 'File must be less than $_maxFileSizeMB MB');
        return false;
      }
    } catch (e) {
      print('Error checking file size: $e');
      _setFieldError(fieldName, 'Error Validating File');
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

  Widget _buildDocumentCard({
    required String title,
    required TextEditingController numberController,
    required TextEditingController expiryDateController,
    required String numberHint,
    required File? file,
    required String? fileName,
    required String fieldKey,
    required String? errorText,
    bool isMandatory = true,
    List<TextInputFormatter>? inputFormatters,
    required FocusNode focusNode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isMandatory ? '$title *' : title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: numberController,
            focusNode: focusNode,
            label: 'Document Number',
            hint: numberHint,
            enabled: widget.enabled,
            inputFormatters: inputFormatters,
            // Removed onChanged setState to reduce rebuilds. Validation happens on blur.
          ),
          const SizedBox(height: 16),
          _buildExpiryDateField(expiryDateController, isMandatory),
          const SizedBox(height: 16),
          FileUploadField(
            label: 'Upload $title',
            fileName: fileName,
            file: file,
            errorText: errorText,
            required: isMandatory,
            enabled: widget.enabled,
            onTap: () => _showUploadOptions(fieldKey),
            onRemove: () => _removeFile(fieldKey),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryDateField(
    TextEditingController controller,
    bool isMandatory,
  ) {
    return GestureDetector(
      onTap: widget.enabled ? () => _selectDate(controller) : null,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          label: isMandatory ? 'Expiry Date *' : 'Expiry Date',
          hint: 'dd/mm/yyyy',
          enabled: widget.enabled,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)), // Only future dates
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format: dd/mm/yyyy
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year;
      controller.text = '$day/$month/$year';
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAdditionalName = widget.additionalDocumentNameController.text
        .trim()
        .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentCard(
          title: 'Business Registration Certificate',
          numberController: widget.businessRegistrationNumberController,
          expiryDateController: widget.businessRegistrationExpiryDateController,
          numberHint: 'Enter registration number',
          file: widget.businessRegistrationFile,
          fileName: widget.businessRegistrationFileName,
          fieldKey: 'business_registration',
          errorText: _showErrors ? _businessRegistrationError : null,
          isMandatory: true,
          focusNode: _businessRegistrationNumberFocus,
        ),
        _buildDocumentCard(
          title: 'GST Registration Certificate',
          numberController: widget.gstCertificateNumberController,
          expiryDateController: widget.gstExpiryDateController,
          numberHint: 'Enter GST number',
          file: widget.gstCertificateFile,
          fileName: widget.gstCertificateFileName,
          fieldKey: 'gst_certificate',
          errorText: _showErrors ? _gstCertificateError : null,
          isMandatory: true,
          focusNode: _gstCertificateNumberFocus,
        ),
        _buildDocumentCard(
          title: 'PAN Card',
          numberController: widget.panCardNumberController,
          expiryDateController: widget.panCardExpiryDateController,
          numberHint: 'Enter PAN number',
          file: widget.panCardFile,
          fileName: widget.panCardFileName,
          fieldKey: 'pan_card',
          errorText: _showErrors ? _panCardError : null,
          isMandatory: true,
          focusNode: _panCardNumberFocus,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.toUpperCase(),
                selection: newValue.selection,
              );
            }),
          ],
        ),
        _buildDocumentCard(
          title: 'Professional License',
          numberController: widget.professionalLicenseNumberController,
          expiryDateController: widget.professionalLicenseExpiryDateController,
          numberHint: 'Enter license number',
          file: widget.professionalLicenseFile,
          fileName: widget.professionalLicenseFileName,
          fieldKey: 'professional_license',
          errorText: _showErrors ? _professionalLicenseError : null,
          isMandatory: true,
          focusNode: _professionalLicenseNumberFocus,
        ),

        // Additional Documents
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
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
                    'Add More Documents (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.additionalDocumentNameController,
                focusNode: _additionalDocumentNameFocus,
                label: 'Document Name',
                hint: 'e.g., Trade License',
                enabled: widget.enabled,
                // Validation on blur via FocusNode
              ),
              if (hasAdditionalName) ...[
                const SizedBox(height: 16),
                _buildExpiryDateField(
                  widget.additionalDocumentExpiryDateController,
                  false,
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
            ],
          ),
        ),
      ],
    );
  }
}
