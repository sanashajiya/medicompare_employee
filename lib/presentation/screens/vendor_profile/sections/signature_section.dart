import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_text_field.dart';

class SignatureSection extends StatefulWidget {
  final SignatureController signatureController;
  final TextEditingController signerNameController;
  final Uint8List? signatureBytes;
  final bool acceptedTerms;
  final bool enabled;
  final Function(Uint8List?) onSignatureSaved;
  final Function(bool) onTermsChanged;
  final Function(bool isValid) onValidationChanged;

  const SignatureSection({
    super.key,
    required this.signatureController,
    required this.signerNameController,
    required this.signatureBytes,
    required this.acceptedTerms,
    required this.enabled,
    required this.onSignatureSaved,
    required this.onTermsChanged,
    required this.onValidationChanged,
  });

  @override
  State<SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<SignatureSection> {
  String? _signerNameError;
  String? _signatureError;
  String? _termsError;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    widget.signerNameController.addListener(_validate);
    _validate();
  }

  @override
  void dispose() {
    widget.signerNameController.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final signerNameError = widget.signerNameController.text.trim().isEmpty
        ? 'Signer name is required'
        : null;
    final signatureError = widget.signatureBytes == null
        ? 'Please provide your digital signature'
        : null;
    final termsError = !widget.acceptedTerms
        ? 'You must accept the Terms and Conditions'
        : null;

    final isValid =
        widget.signerNameController.text.trim().isNotEmpty &&
        widget.signatureBytes != null &&
        widget.acceptedTerms;
    widget.onValidationChanged(isValid);

    if (_showErrors) {
      setState(() {
        _signerNameError = signerNameError;
        _signatureError = signatureError;
        _termsError = termsError;
      });
    }
  }

  @override
  void didUpdateWidget(SignatureSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
  }

  Future<void> _saveSignature() async {
    if (widget.signatureController.isNotEmpty) {
      final bytes = await widget.signatureController.toPngBytes();
      widget.onSignatureSaved(bytes);
      if (!_showErrors) setState(() => _showErrors = true);
      _validate();
    }
  }

  void _clearSignature() {
    widget.signatureController.clear();
    widget.onSignatureSaved(null);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provide your digital signature',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Signer Name Field
        CustomTextField(
          controller: widget.signerNameController,
          label: 'Signer Name *',
          hint: 'Enter the name of the person signing',
          errorText: _showErrors ? _signerNameError : null,
          enabled: widget.enabled,
          onChanged: (_) {
            if (!_showErrors) setState(() => _showErrors = true);
          },
        ),
        const SizedBox(height: 20),
        // Signature Pad Label
        Text(
          'Digital Signature *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Signature Pad
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: _showErrors && _signatureError != null
                  ? AppColors.error
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: widget.signatureController,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.enabled ? _clearSignature : null,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.enabled ? _saveSignature : null,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showErrors && _signatureError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _signatureError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        if (widget.signatureBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Signature saved successfully',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        // Terms and Conditions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: widget.acceptedTerms,
                      onChanged: widget.enabled
                          ? (value) {
                              widget.onTermsChanged(value ?? false);
                              if (!_showErrors)
                                setState(() => _showErrors = true);
                              _validate();
                            }
                          : null,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showErrors && _termsError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 8),
                  child: Text(
                    _termsError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
