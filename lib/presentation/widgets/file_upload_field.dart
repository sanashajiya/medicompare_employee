import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FileUploadField extends StatelessWidget {
  final String label;
  final String? fileName;
  final File? file;
  final String? fileUrl;
  final String? errorText;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool enabled;
  final bool required;

  const FileUploadField({
    super.key,
    required this.label,
    this.fileName,
    this.file,
    this.fileUrl,
    this.errorText,
    required this.onTap,
    this.onRemove,
    this.enabled = true,
    this.required = false,
  });

  bool get _isImage {
    if (fileName != null) {
      final ext = fileName!.toLowerCase();
      return ext.endsWith('.jpg') ||
          ext.endsWith('.jpeg') ||
          ext.endsWith('.png');
    }
    if (fileUrl != null) {
      final ext = fileUrl!.toLowerCase();
      return ext.endsWith('.jpg') ||
          ext.endsWith('.jpeg') ||
          ext.endsWith('.png') ||
          // If URL doesn't have extension, we rely on server content type,
          // but for basic UI we might assume image if it's not explicitly PDF
          !ext.endsWith('.pdf');
    }
    return false;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final hasFile =
        (fileName != null && file != null) ||
        (fileUrl != null && fileUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasFile)
          _buildFilePreview(context)
        else
          _buildUploadButton(context),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surface
              : AppColors.border.withOpacity(0.3),
          border: Border.all(
            color: errorText != null ? AppColors.error : AppColors.border,
            width: errorText != null ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap to upload',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PDF, JPG, PNG (Max 5MB)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Preview area
          if (_isImage && (file != null || fileUrl != null))
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              child: file != null
                  ? Image.file(
                      file!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      fileUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
            )
          else
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: AppColors.error, size: 36),
                  const SizedBox(height: 4),
                  Text(
                    'Document File',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          // File info and actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ??
                            (fileUrl != null ? 'Existing Document' : ''),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (file != null)
                        Text(
                          _formatFileSize(file!.lengthSync()),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textHint),
                        ),
                      if (fileUrl != null && file == null)
                        Text(
                          'Stored on Server',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textHint),
                        ),
                    ],
                  ),
                ),
                // Replace button
                InkWell(
                  onTap: enabled ? onTap : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.refresh,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                // Remove button
                if (onRemove != null)
                  InkWell(
                    onTap: enabled ? onRemove : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
