import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';

class PhotosSection extends StatefulWidget {
  final List<File> frontendImages;
  final List<File> backendImages;
  final bool enabled;
  final Function(List<File>) onFrontendImagesChanged;
  final Function(List<File>) onBackendImagesChanged;
  final Function(bool isValid) onValidationChanged;

  const PhotosSection({
    super.key,
    required this.frontendImages,
    required this.backendImages,
    required this.enabled,
    required this.onFrontendImagesChanged,
    required this.onBackendImagesChanged,
    required this.onValidationChanged,
  });

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _frontendImagesError;
  String? _backendImagesError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _validate();
  }

  void _validate() {
    final frontendError = widget.frontendImages.isEmpty
        ? 'Please upload at least one frontend image'
        : null;
    final backendError = widget.backendImages.isEmpty
        ? 'Please upload at least one backend image'
        : null;

    final isValid =
        widget.frontendImages.isNotEmpty && widget.backendImages.isNotEmpty;
    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _frontendImagesError = frontendError;
        _backendImagesError = backendError;
      });
    }
  }

  @override
  void didUpdateWidget(PhotosSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
  }

  Future<void> _pickImages({required bool isFrontend}) async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isEmpty) return;

      const int maxImages = 30;
      const int maxSizeMB = 3;
      const int maxSizeBytes = maxSizeMB * 1024 * 1024;

      final List<File> currentImages = isFrontend
          ? widget.frontendImages
          : widget.backendImages;

      List<File> validImages = [];

      for (final xFile in pickedImages) {
        final file = File(xFile.path);

        if (file.lengthSync() > maxSizeBytes) {
          setState(() {
            _showErrors = true;
            if (isFrontend) {
              _frontendImagesError =
                  'Each image must be less than $maxSizeMB MB';
            } else {
              _backendImagesError =
                  'Each image must be less than $maxSizeMB MB';
            }
          });
          return;
        }

        if (currentImages.length + validImages.length >= maxImages) {
          setState(() {
            _showErrors = true;
            if (isFrontend) {
              _frontendImagesError = 'Maximum $maxImages images allowed';
            } else {
              _backendImagesError = 'Maximum $maxImages images allowed';
            }
          });
          return;
        }

        validImages.add(file);
      }

      final newImages = [...currentImages, ...validImages];
      if (isFrontend) {
        widget.onFrontendImagesChanged(newImages);
      } else {
        widget.onBackendImagesChanged(newImages);
      }

      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeImage(bool isFrontend, int index) {
    if (isFrontend) {
      final newImages = List<File>.from(widget.frontendImages);
      newImages.removeAt(index);
      widget.onFrontendImagesChanged(newImages);
    } else {
      final newImages = List<File>.from(widget.backendImages);
      newImages.removeAt(index);
      widget.onBackendImagesChanged(newImages);
    }
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload product/service images',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Frontend Images
        _buildImageSection(
          title: 'Frontend Images',
          subtitle: 'UI/UX screenshots and designs',
          icon: Icons.browser_updated_rounded,
          color: AppColors.primary,
          images: widget.frontendImages,
          error: _showErrors ? _frontendImagesError : null,
          onAdd: () => _pickImages(isFrontend: true),
          onRemove: (index) => _removeImage(true, index),
        ),
        const SizedBox(height: 24),
        // Backend Images
        _buildImageSection(
          title: 'Backend Images',
          subtitle: 'Infrastructure and architecture',
          icon: Icons.storage_rounded,
          color: AppColors.secondary,
          images: widget.backendImages,
          error: _showErrors ? _backendImagesError : null,
          onAdd: () => _pickImages(isFrontend: false),
          onRemove: (index) => _removeImage(false, index),
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<File> images,
    required String? error,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withOpacity(0.05),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Select Images',
            icon: Icons.add_photo_alternate_rounded,
            onPressed: widget.enabled ? onAdd : null,
            width: double.infinity,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${images.length} image(s) selected',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  images.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index < images.length - 1 ? 12 : 0,
                    ),
                    child: _buildImageThumbnail(
                      images[index],
                      () => onRemove(index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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
