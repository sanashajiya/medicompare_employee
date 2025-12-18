import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class PhotosSection extends StatefulWidget {
  final List<File> frontStoreImages;
  final bool enabled;
  final Function(List<File>) onFrontStoreImagesChanged;
  final Function(bool isValid) onValidationChanged;

  const PhotosSection({
    super.key,
    required this.frontStoreImages,
    required this.enabled,
    required this.onFrontStoreImagesChanged,
    required this.onValidationChanged,
  });

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _frontStoreImagesError;
  bool _showErrors = false;

  static const int _maxImages = 5;
  static const int _maxSizeMB = 3;
  static const int _maxSizeBytes = _maxSizeMB * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _validate();
  }

  void _validate() {
    final error = widget.frontStoreImages.isEmpty
        ? 'Please upload at least one store image'
        : null;

    final isValid = widget.frontStoreImages.isNotEmpty;
    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _frontStoreImagesError = error;
      });
    }
  }

  @override
  void didUpdateWidget(PhotosSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
  }

  void _showUploadOptions() {
    if (widget.frontStoreImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages images allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
                'Upload Store Image',
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
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromCamera();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        color: AppColors.success,
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromGallery();
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (!_validateImage(file)) return;

      final newImages = [...widget.frontStoreImages, file];
      widget.onFrontStoreImagesChanged(newImages);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to capture image');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final remainingSlots = _maxImages - widget.frontStoreImages.length;

      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedImages.isEmpty) return;

      List<File> validImages = [];

      for (final xFile in pickedImages) {
        if (validImages.length >= remainingSlots) {
          _showErrorSnackbar('Maximum $_maxImages images allowed');
          break;
        }

        final file = File(xFile.path);

        if (file.lengthSync() > _maxSizeBytes) {
          _showErrorSnackbar('Each image must be less than $_maxSizeMB MB');
          continue;
        }

        // Check extension
        final ext = xFile.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(ext)) {
          _showErrorSnackbar('Only JPG, JPEG, PNG formats allowed');
          continue;
        }

        validImages.add(file);
      }

      if (validImages.isNotEmpty) {
        final newImages = [...widget.frontStoreImages, ...validImages];
        widget.onFrontStoreImagesChanged(newImages);
        if (!_showErrors) setState(() => _showErrors = true);
        _validate();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick images');
    }
  }

  bool _validateImage(File file) {
    if (widget.frontStoreImages.length >= _maxImages) {
      _showErrorSnackbar('Maximum $_maxImages images allowed');
      return false;
    }

    if (file.lengthSync() > _maxSizeBytes) {
      _showErrorSnackbar('Image must be less than $_maxSizeMB MB');
      return false;
    }

    return true;
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(widget.frontStoreImages);
    newImages.removeAt(index);
    widget.onFrontStoreImagesChanged(newImages);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload store images',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Front Store Images
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Front Store Images *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Max $_maxImages images (JPG, PNG)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.frontStoreImages.length}/$_maxImages',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: widget.enabled ? _showUploadOptions : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Images',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showErrors && _frontStoreImagesError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _frontStoreImagesError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (widget.frontStoreImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      widget.frontStoreImages.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          right: index < widget.frontStoreImages.length - 1
                              ? 12
                              : 0,
                        ),
                        child: _buildImageThumbnail(
                          widget.frontStoreImages[index],
                          () => _removeImage(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(File imageFile, VoidCallback onRemove) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.border,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}


