import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/file_upload_field.dart';

class DocumentsSection extends StatefulWidget {
  final File? businessRegistrationFile;
  final File? gstCertificateFile;
  final File? panCardFile;
  final File? professionalLicenseFile;
  final String? businessRegistrationFileName;
  final String? gstCertificateFileName;
  final String? panCardFileName;
  final String? professionalLicenseFileName;
  final TextEditingController panCardNumberController;
  final TextEditingController gstCertificateNumberController;
  final TextEditingController businessRegistrationNumberController;
  final TextEditingController professionalLicenseNumberController;
  final bool enabled;
  final Function(String fieldName, File? file, String? fileName) onFileSelected;
  final Function(bool isValid) onValidationChanged;

  const DocumentsSection({
    super.key,
    required this.businessRegistrationFile,
    required this.gstCertificateFile,
    required this.panCardFile,
    required this.professionalLicenseFile,
    required this.businessRegistrationFileName,
    required this.gstCertificateFileName,
    required this.panCardFileName,
    required this.professionalLicenseFileName,
    required this.panCardNumberController,
    required this.gstCertificateNumberController,
    required this.businessRegistrationNumberController,
    required this.professionalLicenseNumberController,
    required this.enabled,
    required this.onFileSelected,
    required this.onValidationChanged,
  });

  @override
  State<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  String? _businessRegistrationError;
  String? _gstCertificateError;
  String? _panCardError;
  String? _professionalLicenseError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _validate();
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

    final isValid =
        businessRegistrationError == null &&
        gstCertificateError == null &&
        panCardError == null &&
        professionalLicenseError == null &&
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
      });
    }
  }

  Future<void> _pickFile(String fieldName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      final file = File(platformFile.path!);

      const int maxFileSizeMB = 5;
      const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

      if (file.lengthSync() > maxFileSizeBytes) {
        setState(() {
          _showErrors = true;
          switch (fieldName) {
            case 'business_registration':
              _businessRegistrationError =
                  'File must be less than $maxFileSizeMB MB';
              break;
            case 'gst_certificate':
              _gstCertificateError = 'File must be less than $maxFileSizeMB MB';
              break;
            case 'pan_card':
              _panCardError = 'File must be less than $maxFileSizeMB MB';
              break;
            case 'professional_license':
              _professionalLicenseError =
                  'File must be less than $maxFileSizeMB MB';
              break;
          }
        });
        return;
      }

      widget.onFileSelected(fieldName, file, platformFile.name);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      // silently fail
    }
  }

  @override
  void didUpdateWidget(DocumentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
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
          errorText: _showErrors ? _businessRegistrationError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _pickFile('business_registration'),
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
          errorText: _showErrors ? _gstCertificateError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _pickFile('gst_certificate'),
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
          errorText: _showErrors ? _panCardError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _pickFile('pan_card'),
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
          errorText: _showErrors ? _professionalLicenseError : null,
          required: true,
          enabled: widget.enabled,
          onTap: () => _pickFile('professional_license'),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.professionalLicenseNumberController,
          label: 'Professional License Number',
          hint: 'Enter license number',
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
