import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/vendor_entity.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/file_upload_field.dart';
import '../../../widgets/rejection_banner.dart';
import '../models/additional_document_model.dart'; // New import

class DocumentsSection extends StatefulWidget {
  final File? businessRegistrationFile;
  final String? businessRegistrationUrl;
  final File? gstCertificateFile;
  final String? gstCertificateUrl;
  final File? panCardFile;
  final String? panCardUrl;
  final File? professionalLicenseFile;
  final String? professionalLicenseUrl;
  final String? businessRegistrationFileName;
  final String?
  gstCertificateFileName; // Keep this as it's used in _buildDocumentCard
  final String? panCardFileName; // Keep this as it's used in _buildDocumentCard
  final String? professionalLicenseFileName;

  // Dynamic Additional Documents
  final List<AdditionalDocumentModel> additionalDocuments;
  final VoidCallback onAddDocument;
  final Function(int) onRemoveDocument;
  final Function(int, File?, String?) onDocumentFileSelected;

  final TextEditingController panCardNumberController;
  final TextEditingController gstCertificateNumberController;
  final TextEditingController businessRegistrationNumberController;
  final TextEditingController professionalLicenseNumberController;

  final TextEditingController businessRegistrationExpiryDateController;
  final TextEditingController gstExpiryDateController;
  final TextEditingController panCardExpiryDateController;
  final TextEditingController professionalLicenseExpiryDateController;

  final bool enabled;
  final Function(String fieldName, File? file, String? fileName) onFileSelected;
  final Function(bool isValid) onValidationChanged;
  final bool showErrors; // New field
  final VendorEntity? vendorDetails; // For rejection highlighting
  final Map<String, bool> reuploadedDocuments;
  final Function(String)? onDocumentReuploaded;

  const DocumentsSection({
    super.key,
    required this.businessRegistrationFile,
    this.businessRegistrationUrl,
    required this.gstCertificateFile,
    this.gstCertificateUrl,
    required this.panCardFile,
    this.panCardUrl,
    required this.professionalLicenseFile,
    this.professionalLicenseUrl,
    required this.businessRegistrationFileName,
    required this.gstCertificateFileName,
    required this.panCardFileName,
    required this.professionalLicenseFileName,
    required this.additionalDocuments, // New
    required this.onAddDocument, // New
    required this.onRemoveDocument, // New
    required this.onDocumentFileSelected, // New
    required this.panCardNumberController,
    required this.gstCertificateNumberController,
    required this.businessRegistrationNumberController,
    required this.professionalLicenseNumberController,
    required this.businessRegistrationExpiryDateController,
    required this.gstExpiryDateController,
    required this.panCardExpiryDateController,
    required this.professionalLicenseExpiryDateController,
    required this.enabled,
    required this.onFileSelected,
    required this.onValidationChanged,
    this.showErrors = false, // New
    this.vendorDetails, // For rejection highlighting
    this.reuploadedDocuments = const {},
    this.onDocumentReuploaded,
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
  // String? _additionalDocumentError; // Removed
  bool _showErrors = false;

  static const int _maxFileSizeMB = 5;
  static const int _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  final FocusNode _businessRegistrationNumberFocus = FocusNode();
  final FocusNode _gstCertificateNumberFocus = FocusNode();
  final FocusNode _panCardNumberFocus = FocusNode();
  final FocusNode _professionalLicenseNumberFocus = FocusNode();
  // final FocusNode _additionalDocumentNameFocus = FocusNode(); // Removed

  @override
  void initState() {
    super.initState();
    // Use FocusNodes for validation on blur
    _businessRegistrationNumberFocus.addListener(_onFocusChange);
    _gstCertificateNumberFocus.addListener(_onFocusChange);
    _panCardNumberFocus.addListener(_onFocusChange);
    _professionalLicenseNumberFocus.addListener(_onFocusChange);
    // _additionalDocumentNameFocus.addListener(_onFocusChange); // Removed

    // Keep validation on date changes as they are picked via dialog
    widget.businessRegistrationExpiryDateController.addListener(_validate);
    widget.gstExpiryDateController.addListener(_validate);
    widget.panCardExpiryDateController.addListener(_validate);
    widget.professionalLicenseExpiryDateController.addListener(_validate);
    // widget.additionalDocumentExpiryDateController.addListener(_validate); // Removed

    // Initial validation without showing errors
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());

    // Auto-validate prefilled data in edit/resume mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validate();
    });
  }

  void _onFocusChange() {
    // Check if any controller has text, implying user interaction has started
    final hasInteraction =
        widget.businessRegistrationNumberController.text.isNotEmpty ||
        widget.gstCertificateNumberController.text.isNotEmpty ||
        widget.panCardNumberController.text.isNotEmpty ||
        widget.professionalLicenseNumberController.text.isNotEmpty;
    // || widget.additionalDocumentNameController.text.isNotEmpty; // Removed

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
    // widget.additionalDocumentExpiryDateController.removeListener(_validate); // Removed

    _businessRegistrationNumberFocus.removeListener(_onFocusChange);
    _gstCertificateNumberFocus.removeListener(_onFocusChange);
    _panCardNumberFocus.removeListener(_onFocusChange);
    _professionalLicenseNumberFocus.removeListener(_onFocusChange);
    // _additionalDocumentNameFocus.removeListener(_onFocusChange); // Removed

    _businessRegistrationNumberFocus.dispose();
    _gstCertificateNumberFocus.dispose();
    _panCardNumberFocus.dispose();
    _professionalLicenseNumberFocus.dispose();
    // _additionalDocumentNameFocus.dispose(); // Removed
    super.dispose();
  }

  @override
  void didUpdateWidget(DocumentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessRegistrationUrl != widget.businessRegistrationUrl ||
        oldWidget.gstCertificateUrl != widget.gstCertificateUrl ||
        oldWidget.panCardUrl != widget.panCardUrl ||
        oldWidget.professionalLicenseUrl != widget.professionalLicenseUrl ||
        // oldWidget.additionalDocumentUrl != widget.additionalDocumentUrl || // Removed
        oldWidget.businessRegistrationFile != widget.businessRegistrationFile ||
        oldWidget.gstCertificateFile != widget.gstCertificateFile ||
        oldWidget.panCardFile != widget.panCardFile ||
        oldWidget.professionalLicenseFile != widget.professionalLicenseFile ||
        // oldWidget.additionalDocumentFile != widget.additionalDocumentFile || // Removed
        oldWidget.additionalDocuments.length !=
            widget
                .additionalDocuments
                .length // New check for additional documents
                ) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validate();
      });
    }
  }

  bool? _lastIsValid;

  void _validate() {
    // Helper to check if file or URL is present
    String? validateDocRequest(File? file, String? url, String label) {
      if (file != null) return Validators.validateFileUpload(file, label);
      if (url != null && url.isNotEmpty) return null; // URL is valid content
      return Validators.validateFileUpload(
        null,
        label,
      ); // Trigger required error
    }

    final businessRegistrationError = validateDocRequest(
      widget.businessRegistrationFile,
      widget.businessRegistrationUrl,
      'Business Registration Certificate',
    );
    final gstCertificateError = validateDocRequest(
      widget.gstCertificateFile,
      widget.gstCertificateUrl,
      'GST Registration Certificate',
    );
    final panCardError = validateDocRequest(
      widget.panCardFile,
      widget.panCardUrl,
      'PAN Card',
    );
    final professionalLicenseError = validateDocRequest(
      widget.professionalLicenseFile,
      widget.professionalLicenseUrl,
      'Professional License',
    );

    // Additional document validation: if name is entered, file is required
    // String? additionalDocumentError; // Removed
    // final hasAdditionalName = widget.additionalDocumentNameController.text // Removed
    //     .trim() // Removed
    //     .isNotEmpty; // Removed
    // if (hasAdditionalName) { // Removed
    //   if (widget.additionalDocumentFile == null && // Removed
    //       (widget.additionalDocumentUrl == null || // Removed
    //           widget.additionalDocumentUrl!.isEmpty)) { // Removed
    //     additionalDocumentError = 'Please upload the additional document'; // Removed
    //   } // Removed
    // } // Removed

    // Validate dynamic additional documents
    bool additionalDocumentsAreValid = true;
    for (final doc in widget.additionalDocuments) {
      if (doc.nameController.text.trim().isEmpty ||
          doc.numberController.text.trim().isEmpty ||
          (doc.file == null && (doc.fileUrl == null || doc.fileUrl!.isEmpty))) {
        additionalDocumentsAreValid = false;
        break;
      }
    }

    // For overall validity check, we check if mandatory docs are present (either file or url)
    final bool hasBusinessReg =
        widget.businessRegistrationFile != null ||
        (widget.businessRegistrationUrl?.isNotEmpty ?? false);
    final bool hasGst =
        widget.gstCertificateFile != null ||
        (widget.gstCertificateUrl?.isNotEmpty ?? false);
    final bool hasPan =
        widget.panCardFile != null || (widget.panCardUrl?.isNotEmpty ?? false);
    final bool hasProfLicense =
        widget.professionalLicenseFile != null ||
        (widget.professionalLicenseUrl?.isNotEmpty ?? false);

    final isValid =
        businessRegistrationError == null &&
        gstCertificateError == null &&
        panCardError == null &&
        professionalLicenseError == null &&
        // additionalDocumentError == null && // Removed
        hasBusinessReg &&
        hasGst &&
        hasPan &&
        hasProfLicense &&
        widget.businessRegistrationNumberController.text.isNotEmpty &&
        widget.businessRegistrationExpiryDateController.text.isNotEmpty &&
        widget.gstCertificateNumberController.text.isNotEmpty &&
        widget.gstExpiryDateController.text.isNotEmpty &&
        widget.panCardNumberController.text.isNotEmpty &&
        widget.panCardExpiryDateController.text.isNotEmpty &&
        widget.professionalLicenseNumberController.text.isNotEmpty &&
        widget.professionalLicenseExpiryDateController.text.isNotEmpty &&
        additionalDocumentsAreValid; // New validation for dynamic docs

    if (_lastIsValid != isValid) {
      _lastIsValid = isValid;
      // Defer callback to next frame to avoid build collisions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onValidationChanged(isValid);
      });
    }

    if (widget.showErrors) {
      // Changed from _showErrors to widget.showErrors
      // Only set state if something actually changed to avoid rebuilds
      if (_businessRegistrationError != businessRegistrationError ||
          _gstCertificateError != gstCertificateError ||
          _panCardError != panCardError ||
          _professionalLicenseError != professionalLicenseError) {
        // _additionalDocumentError != additionalDocumentError) { // Removed
        setState(() {
          _businessRegistrationError = businessRegistrationError;
          _gstCertificateError = gstCertificateError;
          _panCardError = panCardError;
          _professionalLicenseError = professionalLicenseError;
          // _additionalDocumentError = additionalDocumentError; // Removed
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
      widget.onDocumentReuploaded?.call(
        fieldName,
      ); // Notify parent about re-upload
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
      widget.onDocumentReuploaded?.call(
        fieldName,
      ); // Notify parent about re-upload
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
      widget.onDocumentReuploaded?.call(
        fieldName,
      ); // Notify parent about re-upload
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick PDF');
    }
  }

  // Generic pick image function for additional documents
  Future<void> _pickImage(
    ImageSource source,
    Function(File?, String?) onFilePicked,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedFile == null) {
        onFilePicked(null, null);
        return;
      }

      final file = File(pickedFile.path);
      final fileName = pickedFile.name;

      // For additional documents, we don't use _setFieldError directly,
      // but the validation will happen in _validateForm
      if (!await _validateFileAsync(
        file,
        fileName,
        'additional_document_dynamic',
      )) {
        onFilePicked(null, null); // Clear selection if validation fails
        return;
      }

      onFilePicked(file, fileName);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick image');
      onFilePicked(null, null);
    }
  }

  // Generic pick PDF function for additional documents
  Future<void> _pickPdf(Function(File?, String?) onFilePicked) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        onFilePicked(null, null);
        return;
      }

      final platformFile = result.files.first;
      if (platformFile.path == null) {
        onFilePicked(null, null);
        return;
      }

      final file = File(platformFile.path!);
      final fileName = platformFile.name;

      if (!await _validateFileAsync(
        file,
        fileName,
        'additional_document_dynamic',
      )) {
        onFilePicked(null, null); // Clear selection if validation fails
        return;
      }

      onFilePicked(file, fileName);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick PDF');
      onFilePicked(null, null);
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
        // case 'additional_document': // Removed
        //   _additionalDocumentError = error; // Removed
        //   break; // Removed
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
    // Note: onFileSelected(null) clears the file.
    // If there was an existing URL, removing the file might mean "I want to remove the new file I just uploaded and revert to empty" or "I want to clear everything".
    // Usually, hitting remove on a "File with URL" field implies clearing the URL too if we support clearing.
    // But since these are mandatory fields, "removing" usually just clears current selection.
    // If a URL exists, FileUploadField displays it.
    // If I hit remove, I probably want to clear that URL too? But I can't clear URL via `onFileSelected`.
    // The parent manages state. If I want to clear URL, I need a callback for that or strict handling.
    // For now, let's assume `onFileSelected(fieldName, null, null)` just clears the *newly selected file*.
    // If I want to clear the URL, I need the parent to know.
    // However, since `DocumentsSection` fields are mandatory, users essentially replace them.
    _validate();
  }

  /// Helper method to get document verification status
  Map<String, dynamic>? _getDocumentStatus(String docId) {
    if (widget.vendorDetails?.documentStatuses == null) return null;

    try {
      return widget.vendorDetails!.documentStatuses!.firstWhere((status) {
        final statusDocId = status['docId']?.toString().toLowerCase() ?? '';
        final statusName = status['name']?.toString().toLowerCase() ?? '';
        final searchId = docId.toLowerCase().replaceAll('_', ' ');

        // Match by name field (e.g., "PAN Card" matches "pan_card")
        // or by doc_id if it contains the search term
        return statusName.contains(searchId) ||
            searchId.contains(statusName) ||
            statusDocId == docId.toLowerCase() ||
            statusName.replaceAll(' ', '_') == docId.toLowerCase();
      });
    } catch (e) {
      return null;
    }
  }

  Widget _buildDocumentCard({
    required String title,
    required TextEditingController numberController,
    required TextEditingController expiryDateController,
    required String numberHint,
    required File? file,
    required String? url,
    required String? fileName,
    required String fieldKey,
    required String? errorText,
    bool isMandatory = true,
    List<TextInputFormatter>? inputFormatters,
    required FocusNode focusNode,
  }) {
    // Check document verification status
    final docStatus = _getDocumentStatus(fieldKey);
    final isPendingVendor =
        widget.vendorDetails?.verifyStatus?.toLowerCase() == 'pending' ||
        widget.vendorDetails?.verifyStatus?.toLowerCase() == 'rejected';

    // Determine if we are in Edit Mode
    final isEditing = widget.vendorDetails != null;

    // Check if reuploaded locally
    final isReuploaded = widget.reuploadedDocuments[fieldKey] == true;

    // API Status
    final apiStatus = docStatus?['isVerified']?.toString().toLowerCase();

    // Effective Status:
    // If NOT editing -> null (no status)
    // If editing:
    //   If reuploaded -> 'pending'
    //   Else -> API Status
    final effectiveStatus = isEditing
        ? (isReuploaded ? 'pending' : (apiStatus ?? 'pending'))
        : null;

    final isRejected = isPendingVendor && effectiveStatus == 'rejected';
    final isApproved = effectiveStatus == 'approved';
    final isPending = effectiveStatus == 'pending';
    final rejectionReason = docStatus?['rejectionReason']?.toString();

    // Show status UI only if editing
    final showStatus = isEditing;

    // Colors
    final statusColor = showStatus
        ? (isRejected
              ? AppColors.error
              : (isApproved ? AppColors.success : AppColors.warning))
        : AppColors.border; // Neutral validation color or just border

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: showStatus ? statusColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showStatus
              ? statusColor.withOpacity(isPending ? 1.0 : 0.5)
              : AppColors.border.withOpacity(0.5),
          width: showStatus && (isRejected || isPending) ? 2 : 1,
        ),
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
          // Document Info & Status - Only show if Editing
          if (showStatus)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(isPending ? 1.0 : 0.5),
                  width: isRejected || isPending ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isRejected
                        ? Icons.error_outline
                        : (isApproved
                              ? Icons.check_circle
                              : Icons.hourglass_empty),
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRejected
                              ? 'Rejected – Action Required'
                              : (isApproved ? 'Verified' : 'Pending Approval'),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (rejectionReason != null && isRejected)
                          Text(
                            rejectionReason,
                            style: TextStyle(color: statusColor, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          CustomTextField(
            controller: numberController,
            focusNode: focusNode,
            label: 'Document Number',
            hint: numberHint,
            enabled: widget.enabled && !isApproved, // Disable if approved
            inputFormatters: inputFormatters,
            onChanged: (_) => _validate(), // Added onChanged for validation
          ),
          const SizedBox(height: 16),
          _buildExpiryDateField(
            expiryDateController,
            isMandatory,
            isApproved: isApproved,
          ),
          const SizedBox(height: 16),
          FileUploadField(
            label: 'Upload $title',
            fileName: fileName,
            file: file,
            fileUrl: url,
            errorText: errorText,
            required: isMandatory,
            enabled:
                widget.enabled && !isApproved, // Disable upload if approved
            onTap: () => _showUploadOptions(fieldKey),
            onRemove: isApproved
                ? null
                : () => _removeFile(fieldKey), // Disable remove if approved
          ),
          // Show rejection banner if rejected
          if (isRejected &&
              rejectionReason != null &&
              rejectionReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: RejectionBanner(
                reason: rejectionReason,
                title: 'Document Rejected',
                onReupload: widget.enabled
                    ? () {
                        widget.onDocumentReuploaded?.call(fieldKey);
                        _showUploadOptions(fieldKey);
                      }
                    : null,
              ),
            ),
          // Show approved lock message
          if (isApproved)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This document has been approved and cannot be modified',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpiryDateField(
    TextEditingController controller,
    bool isMandatory, {
    bool isApproved = false,
  }) {
    return GestureDetector(
      onTap: (widget.enabled && !isApproved)
          ? () => _selectDate(controller)
          : null,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          label: isMandatory ? 'Expiry Date *' : 'Expiry Date',
          hint: 'yyyy-mm-dd',
          enabled: widget.enabled && !isApproved,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onChanged: (_) => _validate(), // Added onChanged for validation
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
      // Format: yyyy-mm-dd (ISO 8601) to satisfy backend Date casting
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year;
      controller.text = '$year-$month-$day';
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final hasAdditionalName = widget.additionalDocumentNameController.text // Removed
    //     .trim() // Removed
    //     .isNotEmpty; // Removed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentCard(
          title: 'Business Registration Certificate',
          numberController: widget.businessRegistrationNumberController,
          expiryDateController: widget.businessRegistrationExpiryDateController,
          numberHint: 'Enter registration number',
          file: widget.businessRegistrationFile,
          url: widget.businessRegistrationUrl,
          fileName: widget.businessRegistrationFileName,
          fieldKey: 'business_registration',
          errorText: widget.showErrors
              ? _businessRegistrationError
              : null, // Changed to widget.showErrors
          isMandatory: true,
          focusNode: _businessRegistrationNumberFocus,
        ),
        _buildDocumentCard(
          title: 'GST Registration Certificate',
          numberController: widget.gstCertificateNumberController,
          expiryDateController: widget.gstExpiryDateController,
          numberHint: 'Enter GST number',
          file: widget.gstCertificateFile,
          url: widget.gstCertificateUrl,
          fileName: widget.gstCertificateFileName,
          fieldKey: 'gst_certificate',
          errorText: widget.showErrors
              ? _gstCertificateError
              : null, // Changed to widget.showErrors
          isMandatory: true,
          focusNode: _gstCertificateNumberFocus,
        ),
        _buildDocumentCard(
          title: 'PAN Card',
          numberController: widget.panCardNumberController,
          expiryDateController: widget.panCardExpiryDateController,
          numberHint: 'Enter PAN number',
          file: widget.panCardFile,
          url: widget.panCardUrl,
          fileName: widget.panCardFileName,
          fieldKey: 'pan_card',
          errorText: widget.showErrors
              ? _panCardError
              : null, // Changed to widget.showErrors
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
          url: widget.professionalLicenseUrl,
          fileName: widget.professionalLicenseFileName,
          fieldKey: 'professional_license',
          errorText: widget.showErrors
              ? _professionalLicenseError
              : null, // Changed to widget.showErrors
          isMandatory: true,
          focusNode: _professionalLicenseNumberFocus,
        ),

        // Additional Documents Header
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Additional Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.enabled)
              TextButton.icon(
                onPressed: widget.onAddDocument,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add Document'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Dynamic List of Documents
        if (widget.additionalDocuments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text(
                'No additional documents added.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...widget.additionalDocuments.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;

            // Status Logic for Additional Documents
            Map<String, dynamic>? docStatus;
            try {
              if (widget.vendorDetails?.documentStatuses != null) {
                // Try to find status by matching name or ID
                docStatus = widget.vendorDetails!.documentStatuses!.firstWhere((
                  status,
                ) {
                  final statusName =
                      status['name']?.toString().toLowerCase().trim() ?? '';
                  final currentName = doc.nameController.text
                      .toLowerCase()
                      .trim();
                  // Match by name if available, or by doc_id if needed
                  return statusName == currentName && currentName.isNotEmpty;
                }, orElse: () => {});
              }
            } catch (e) {
              docStatus = null;
            }

            // Determine if we are in Edit Mode
            final isEditing = widget.vendorDetails != null;

            final isPendingVendor =
                widget.vendorDetails?.verifyStatus?.toLowerCase() ==
                    'pending' ||
                widget.vendorDetails?.verifyStatus?.toLowerCase() == 'rejected';

            // Check if newly uploaded (file is not null implies a new selection)
            final isNewUpload = doc.file != null;

            final apiStatus = docStatus?['isVerified']
                ?.toString()
                .toLowerCase();

            // Effective Status
            final effectiveStatus = isEditing
                ? (isNewUpload ? 'pending' : (apiStatus ?? 'pending'))
                : null;

            final isRejected = isPendingVendor && effectiveStatus == 'rejected';
            final isApproved = effectiveStatus == 'approved';
            final isPending = effectiveStatus == 'pending';
            final rejectionReason = docStatus?['rejectionReason']?.toString();

            // Show status UI only if editing and name is entered
            final showStatus =
                isEditing && doc.nameController.text.trim().isNotEmpty;

            // Colors
            final statusColor = showStatus
                ? (isRejected
                      ? AppColors.error
                      : (isApproved ? AppColors.success : AppColors.warning))
                : Colors.grey.shade300;

            // Validation logic for dynamic fields
            final bool nameError =
                widget.showErrors && doc.nameController.text.isEmpty;
            final bool numberError =
                widget.showErrors && doc.numberController.text.isEmpty;
            final bool fileError =
                widget.showErrors && doc.file == null && doc.fileUrl == null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: showStatus
                    ? statusColor.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showStatus
                      ? statusColor.withOpacity(isPending ? 1.0 : 0.5)
                      : Colors.grey.shade300,
                  width: showStatus && (isRejected || isPending) ? 2 : 1,
                ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Document #${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (widget.enabled && !isApproved)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'Remove Document',
                          onPressed: () => widget.onRemoveDocument(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),

                  // Status Banner
                  if (showStatus) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(isPending ? 1.0 : 0.5),
                          width: isRejected || isPending ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRejected
                                ? Icons.error_outline
                                : (isApproved
                                      ? Icons.check_circle
                                      : Icons.hourglass_empty),
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRejected
                                      ? 'Rejected – Action Required'
                                      : (isApproved
                                            ? 'Verified'
                                            : 'Pending Approval'),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (rejectionReason != null && isRejected)
                                  Text(
                                    rejectionReason,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: doc.nameController,
                    label: 'Document Name',
                    hint: 'e.g. ISO Certificate',
                    enabled: widget.enabled && !isApproved,
                    errorText: nameError ? 'Required' : null,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: doc.numberController,
                    label: 'Document Number',
                    hint: 'Enter document number',
                    enabled: widget.enabled && !isApproved,
                    errorText: numberError ? 'Required' : null,
                    onChanged: (_) => _validate(),
                  ),
                  const SizedBox(height: 16),
                  _buildExpiryDateField(
                    doc.expiryDateController,
                    false,
                    isApproved: isApproved,
                  ),
                  const SizedBox(height: 16),
                  FileUploadField(
                    label: 'Upload Document',
                    fileName: doc.fileName,
                    file: doc.file,
                    fileUrl: doc.fileUrl,
                    errorText: fileError ? 'File required' : null,
                    required: true,
                    enabled: widget.enabled && !isApproved,
                    onTap: () => _showAdditionalDocUploadOptions(index),
                    onRemove: isApproved
                        ? null
                        : () =>
                              widget.onDocumentFileSelected(index, null, null),
                  ),

                  // Show rejection banner if rejected
                  if (isRejected &&
                      (rejectionReason != null ||
                          effectiveStatus == 'rejected'))
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: RejectionBanner(
                        reason:
                            rejectionReason ??
                            "Reupload to continue verification.",
                        title: 'Document Rejected',
                        onReupload: widget.enabled
                            ? () {
                                _showAdditionalDocUploadOptions(index);
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showAdditionalDocUploadOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera, (file, name) {
                    widget.onDocumentFileSelected(index, file, name);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery, (file, name) {
                    widget.onDocumentFileSelected(index, file, name);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Pick PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickPdf((file, name) {
                    widget.onDocumentFileSelected(index, file, name);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
