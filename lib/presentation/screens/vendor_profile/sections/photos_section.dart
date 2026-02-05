import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

class PhotosSection extends StatefulWidget {
  final List<File> frontStoreImages;
  final List<String> frontStoreImageUrls;
  final File? storeLogo;
  final String? storeLogoUrl;
  final File? profileBanner;
  final String? profileBannerUrl;
  final bool enabled;
  final Function(List<File>) onFrontStoreImagesChanged;
  final Function(List<String>) onFrontStoreImageUrlsChanged;
  final Function(File?) onStoreLogoChanged;
  final Function(File?) onProfileBannerChanged;
  final Function(bool isValid) onValidationChanged;

  const PhotosSection({
    super.key,
    required this.frontStoreImages,
    this.frontStoreImageUrls = const [],
    required this.storeLogo,
    this.storeLogoUrl,
    required this.profileBanner,
    this.profileBannerUrl,
    required this.enabled,
    required this.onFrontStoreImagesChanged,
    required this.onFrontStoreImageUrlsChanged,
    required this.onStoreLogoChanged,
    required this.onProfileBannerChanged,
    required this.onValidationChanged,
  });

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _storeLogoError;
  String? _profileBannerError;
  String? _frontStoreImagesError;
  bool _showErrors = false;

  static const int _maxImages = 5;
  static const int _maxSizeMB = 5;
  static const int _maxSizeBytes = _maxSizeMB * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    // Initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());

    // Auto-validate prefilled data in edit/resume mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validate();
    });
  }

  @override
  void didUpdateWidget(PhotosSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeLogo != widget.storeLogo ||
        oldWidget.storeLogoUrl != widget.storeLogoUrl ||
        oldWidget.profileBanner != widget.profileBanner ||
        oldWidget.profileBannerUrl != widget.profileBannerUrl ||
        oldWidget.frontStoreImages.length != widget.frontStoreImages.length ||
        oldWidget.frontStoreImageUrls.length !=
            widget.frontStoreImageUrls.length) {
      _validate();
    }
  }

  void _validate() {
    String? storeLogoError;
    final hasStoreLogo =
        widget.storeLogo != null ||
        (widget.storeLogoUrl != null && widget.storeLogoUrl!.isNotEmpty);
    if (!hasStoreLogo) {
      storeLogoError = 'Store Logo is required';
    }

    String? profileBannerError;
    final hasProfileBanner =
        widget.profileBanner != null ||
        (widget.profileBannerUrl != null &&
            widget.profileBannerUrl!.isNotEmpty);
    if (!hasProfileBanner) {
      profileBannerError = 'Profile Banner is required';
    }

    String? frontStoreImagesError;
    final hasStoreImages =
        widget.frontStoreImages.isNotEmpty ||
        widget.frontStoreImageUrls.isNotEmpty;
    if (!hasStoreImages) {
      frontStoreImagesError = 'Please upload at least one store image';
    }

    final isValid = hasStoreLogo && hasProfileBanner && hasStoreImages;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onValidationChanged(isValid);
      }
    });

    if (_showErrors) {
      setState(() {
        _storeLogoError = storeLogoError;
        _profileBannerError = profileBannerError;
        _frontStoreImagesError = frontStoreImagesError;
      });
    }
  }

  Future<void> _pickStoreLogo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      if (!_validateFile(file, 'Store Logo')) return;

      widget.onStoreLogoChanged(file);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick store logo');
    }
  }

  Future<void> _pickProfileBanner() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 480,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      if (!_validateFile(file, 'Profile Banner')) return;

      widget.onProfileBannerChanged(file);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to pick profile banner');
    }
  }

  void _showStoreImagesUploadOptions() {
    final totalImages =
        widget.frontStoreImages.length + widget.frontStoreImageUrls.length;
    if (totalImages >= _maxImages) {
      _showErrorSnackbar('Maximum $_maxImages images allowed');
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
                          _pickStoreImageFromCamera();
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
                          _pickStoreImageFromGallery();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStoreImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1500,
        maxHeight: 1500,
      );

      if (pickedFile == null) return;
      final file = File(pickedFile.path);
      if (!_validateFile(file, 'Store Image')) return;

      final newImages = [...widget.frontStoreImages, file];
      widget.onFrontStoreImagesChanged(newImages);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    } catch (e) {
      _showErrorSnackbar('Failed to capture image');
    }
  }

  Future<void> _pickStoreImageFromGallery() async {
    try {
      final totalImages =
          widget.frontStoreImages.length + widget.frontStoreImageUrls.length;
      final remainingSlots = _maxImages - totalImages;

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
        if (_validateFile(file, 'Store Image', showSnackbar: false)) {
          validImages.add(file);
        }
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

  bool _validateFile(File file, String fieldName, {bool showSnackbar = true}) {
    if (file.lengthSync() > _maxSizeBytes) {
      if (showSnackbar) {
        _showErrorSnackbar('$fieldName must be less than $_maxSizeMB MB');
      }
      return false;
    }

    // Check extension
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
      if (showSnackbar) {
        _showErrorSnackbar('Unsupported format. Use JPG, PNG, WebP, GIF');
      }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Store Logo
        _buildUploadSection(
          title: 'Store Logo',
          isRequired: true,
          errorText: _showErrors ? _storeLogoError : null,
          content: _buildSingleUploadCard(
            file: widget.storeLogo,
            url: widget.storeLogoUrl,
            label: 'Tap to upload logo',
            successLabel: 'Logo available',
            onTap: widget.enabled ? _pickStoreLogo : null,
            onRemove:
                widget.enabled &&
                    (widget.storeLogo != null || widget.storeLogoUrl != null)
                ? () {
                    if (widget.storeLogo != null) {
                      widget.onStoreLogoChanged(null);
                    }
                    if (widget.storeLogoUrl != null) {
                      // We can't clear URL via valid callback as it might be 'onStoreLogoChanged' for File.
                      // Parent needs to handle this or we treat URL as persistent unless file overwrites.
                      // To support clearing URL, parent logic needs update.
                      // For now, let's assume 'onStoreLogoChanged(null)' implies clearing selection logic in parent?
                      // Actually, we usually can't 'remove' a persistent logo without uploading a new one or explicit delete API.
                      // But for Edit mode, we might just let them replace it.
                      // If we want to allow removing, we might need a separate callback or just hide it.
                      // Let's assume hitting remove on URL calls onStoreLogoChanged(null) AND we might need a way to clear URL in parent.
                      // Assuming parent rebuilds with url=null? No, parent state has the URL.
                      // Let's just allow REPLACING for now if it's a URL.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please upload a new logo to replace the existing one.',
                          ),
                        ),
                      );
                    } else {
                      widget.onStoreLogoChanged(null);
                    }
                    _validate();
                  }
                : null,
            isWide: false,
          ),
          guidelines: [
            'Shape: Square (1:1 aspect ratio)',
            'Min: 200x200px, Max: 800x800px',
            'Formats: JPG, PNG • Max: 5MB',
          ],
        ),

        const SizedBox(height: 24),

        // 2. Profile Banner
        _buildUploadSection(
          title: 'Profile Banner',
          isRequired: true,
          errorText: _showErrors ? _profileBannerError : null,
          content: _buildSingleUploadCard(
            file: widget.profileBanner,
            url: widget.profileBannerUrl,
            label: 'Tap to upload banner',
            successLabel: 'Banner available',
            onTap: widget.enabled ? _pickProfileBanner : null,
            onRemove:
                widget.enabled &&
                    (widget.profileBanner != null ||
                        widget.profileBannerUrl != null)
                ? () {
                    if (widget.profileBanner != null) {
                      widget.onProfileBannerChanged(null);
                    } else {
                      // See Store Logo comment about removing existing URL assets
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please upload a new banner to replace the existing one.',
                          ),
                        ),
                      );
                    }
                    _validate();
                  }
                : null,
            isWide: true,
          ),
          guidelines: [
            'Ratio: 4:1 (Landscape)',
            'Min: 800x200px, Max: 1920x480px',
            'Formats: JPG, PNG • Max: 5MB',
          ],
        ),

        const SizedBox(height: 24),

        // 3. Store Gallery Images
        _buildUploadSection(
          title: 'Store Gallery Images',
          isRequired: true,
          countLabel:
              '${widget.frontStoreImages.length + widget.frontStoreImageUrls.length}/$_maxImages uploaded',
          errorText: _showErrors ? _frontStoreImagesError : null,
          content: Column(
            children: [
              InkWell(
                onTap: widget.enabled ? _showStoreImagesUploadOptions : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload store images',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.frontStoreImages.isNotEmpty ||
                  widget.frontStoreImageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Display remote URLs
                      ...List.generate(
                        widget.frontStoreImageUrls.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildImageThumbnail(
                            width: 80,
                            height: 80,
                            file: null,
                            url: widget.frontStoreImageUrls[index],
                            onRemove: () {
                              if (widget.enabled) {
                                final newUrls = List<String>.from(
                                  widget.frontStoreImageUrls,
                                );
                                newUrls.removeAt(index);
                                widget.onFrontStoreImageUrlsChanged(newUrls);
                                _validate();
                              }
                            },
                          ),
                        ),
                      ),
                      // Display local Files
                      ...List.generate(
                        widget.frontStoreImages.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            right: index < widget.frontStoreImages.length - 1
                                ? 12
                                : 0,
                          ),
                          child: _buildImageThumbnail(
                            width: 80,
                            height: 80,
                            file: widget.frontStoreImages[index],
                            url: null,
                            onRemove: () {
                              if (widget.enabled) {
                                final newImages = List<File>.from(
                                  widget.frontStoreImages,
                                );
                                newImages.removeAt(index);
                                widget.onFrontStoreImagesChanged(newImages);
                                _validate();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          guidelines: [
            'Max 5 images',
            'Formats: JPG, PNG, WebP, GIF • Max: 5MB per image',
          ],
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required bool isRequired,
    required Widget content,
    String? errorText,
    String? countLabel,
    List<String>? guidelines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRequired ? '$title *' : title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (countLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        content,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        if (guidelines != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: guidelines
                  .map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Expanded(
                            child: Text(
                              g,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleUploadCard({
    required File? file,
    required String? url,
    required String label,
    required String successLabel,
    required VoidCallback? onTap,
    required VoidCallback? onRemove,
    required bool isWide,
  }) {
    final bool hasFile = file != null;
    final bool hasUrl = url != null && url.isNotEmpty;
    final bool hasImage = hasFile || hasUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: isWide ? 150 : 150, // Keep height consistent or responsive
        decoration: BoxDecoration(
          color: hasImage ? Colors.white : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage
                ? AppColors.success
                : AppColors.primary.withOpacity(0.3),
            width: hasImage ? 1.5 : 1,
            style: hasImage ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: hasFile
                        ? Image.file(file!, fit: BoxFit.cover)
                        : Image.network(
                            url!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          successLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWide
                        ? Icons.image_aspect_ratio_rounded
                        : Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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

  Widget _buildImageThumbnail({
    required double width,
    required double height,
    File? file,
    String? url,
    required VoidCallback onRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
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
            child: file != null
                ? Image.file(
                    file,
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
                  )
                : Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.border,
                        child: const Icon(
                          Icons.broken_image_outlined,
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
