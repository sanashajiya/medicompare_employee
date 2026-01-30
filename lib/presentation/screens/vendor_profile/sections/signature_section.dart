import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final Function(bool) onConsentChanged;
  final Function(bool) onPricingAgreementChanged;
  final Function(bool) onSlvAgreementChanged;
  final bool consentAccepted;
  final bool pricingAgreementAccepted;
  final bool slvAgreementAccepted;

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
    required this.onConsentChanged,
    required this.onPricingAgreementChanged,
    required this.onSlvAgreementChanged,
    required this.consentAccepted,
    required this.pricingAgreementAccepted,
    required this.slvAgreementAccepted,
  });

  @override
  State<SignatureSection> createState() => _SignatureSectionState();
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class _SignatureSectionState extends State<SignatureSection> {
  String? _signerNameError;
  String? _signatureError;
  String? _termsError;
  String? _consentError;
  String? _pricingError;
  String? _slvError;
  bool _showErrors = false;
  // bool _isEditingSignature = false; // Unused

  @override
  void initState() {
    super.initState();
    widget.signerNameController.addListener(_validate);
    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  @override
  void dispose() {
    widget.signerNameController.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final isValid =
        widget.signerNameController.text.trim().isNotEmpty &&
        widget.signatureBytes != null &&
        widget.acceptedTerms &&
        widget.consentAccepted &&
        widget.pricingAgreementAccepted &&
        widget.slvAgreementAccepted;

    widget.onValidationChanged(isValid);

    if (_showErrors) {
      _updateErrors();
    }
  }

  void _updateErrors() {
    setState(() {
      _signerNameError = widget.signerNameController.text.trim().isEmpty
          ? 'Signer name is required'
          : null;
      _signatureError = widget.signatureBytes == null
          ? 'Please provide your digital signature'
          : null;
      _termsError = !widget.acceptedTerms
          ? 'You must accept the Terms and Conditions'
          : null;
      _consentError = !widget.consentAccepted ? 'Consent is required' : null;
      _pricingError = !widget.pricingAgreementAccepted
          ? 'Pricing agreement is required'
          : null;
      _slvError = !widget.slvAgreementAccepted
          ? 'SLV agreement is required'
          : null;
    });
  }

  Future<void> _generateAndOpenPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Vendor Agreement')),
              pw.SizedBox(height: 20),
              pw.Text('Signer Name: ${widget.signerNameController.text}'),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
              pw.Paragraph(
                text:
                    'This agreement confirms that the vendor has accepted all terms and conditions, pricing models, and service level agreements (SLVs) as stipulated by the platform.',
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Authorized Signature:'),
                  if (widget.signatureBytes != null)
                    pw.Image(
                      pw.MemoryImage(widget.signatureBytes!),
                      width: 100,
                      height: 50,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/vendor_agreement.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the file (requires open_file or similar, executing minimal open command if possible or just showing snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agreement generated at ${file.path}')),
      );
      // Actual file opening would depend on another package like open_filex, omitting to avoid adding deps blindly.
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to generate PDF')));
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
        // Show saved signature preview if available
        if (widget.signatureBytes != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saved Signature (Restored from draft)',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      widget.signatureBytes!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can clear and redraw if needed',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 16), // Avoid double spacing
        ],
        // Signature Pad
        // Signature Pad - Only show if NO signature is saved
        // Signature Pad - Only show if NO signature is saved
        if (widget.signatureBytes == null) ...[
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
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.enabled ? _saveSignature : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save Signature'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Edit Signature Button if saved
        if (widget.signatureBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton.icon(
                onPressed: widget.enabled
                    ? () {
                        setState(() {});
                        // Logic to edit?
                        // Tapping "Edit" implies we want to redraw.
                        // The current UI shows 'Clear' and 'Redraw' buttons anyway when signature is visible?
                        // Ah, the requested design says:
                        // "Show only one signature preview box... Provide an Edit Signature button"
                        // "Remove any duplicate preview or restored signature containers"
                        // My code currently shows 'Saved Signature' Box AND the Drawing Pad below it.
                        // I should HIDE the drawing pad if signatureBytes != null.

                        _clearSignature(); // This clears it, effectively entering "Edit mode"
                      }
                    : null,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Signature'),
              ),
            ),
          ),

        if (_showErrors && _signatureError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _signatureError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        // Show success indicator only if signature was just saved (not restored)
        // The preview above already shows the restored signature
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
                              if (!_showErrors) {
                                setState(() => _showErrors = true);
                              }
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),

                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openUrl(
                                  'https://medicompares.com/policies/terms-and-conditions',
                                );
                              },
                          ),

                          const TextSpan(text: ' and '),

                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openUrl(
                                  'https://medicompares.com/policies/privacy-policy',
                                );
                              },
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

        const SizedBox(height: 24),

        // Consent & Declaration
        _buildCheckboxSection(
          title: 'Consent & Declaration *',
          content:
              'I hereby confirm that all the information provided is accurate and I authorize verification of the submitted documents.',
          value: widget.consentAccepted,
          onChanged: widget.onConsentChanged,
          errorText: _showErrors ? _consentError : null,
        ),

        const SizedBox(height: 24),

        // Pricing Agreement
        _buildRadioSection(
          title: 'Pricing Agreement *',
          question:
              'Do you agree to the platform’s pricing terms, including commission rates and payment conditions?',
          value: widget.pricingAgreementAccepted,
          onChanged: widget.onPricingAgreementChanged,
          errorText: _showErrors ? _pricingError : null,
          warningText:
              'You cannot proceed with registration if you don’t agree to the pricing terms.',
        ),

        const SizedBox(height: 24),

        // SLV Agreement
        _buildRadioSection(
          title: 'SLV Agreement *',
          question:
              'Do you agree to the Service Level & Value commitments, including performance standards and support protocols?',
          value: widget.slvAgreementAccepted,
          onChanged: widget.onSlvAgreementChanged,
          errorText: _showErrors ? _slvError : null,
          warningText:
              'You cannot proceed with registration if you don’t agree to the SLV terms.',
        ),

        const SizedBox(height: 32),

        // Generated Vendor Agreement
        if (widget.signatureBytes != null &&
            widget.acceptedTerms &&
            widget.consentAccepted &&
            widget.pricingAgreementAccepted &&
            widget.slvAgreementAccepted)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Generated Vendor Agreement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (widget.signatureBytes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Agreement ID: VA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Dummy ID
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _generateAndOpenPdf,
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 18,
                        ),
                        label: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateAndOpenPdf,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCheckboxSection({
    required String title,
    required String content,
    required bool value,
    required Function(bool) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: value,
                  onChanged: widget.enabled
                      ? (v) {
                          onChanged(v ?? false);
                          if (!_showErrors) setState(() => _showErrors = true);
                          _validate();
                        }
                      : null,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(content, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildRadioSection({
    required String title,
    required String question,
    required bool value,
    required Function(bool) onChanged,
    String? errorText,
    String? warningText,
  }) {
    // Value is basically "Accepted" vs "Not Accepted".
    // We need to track tri-state for radio?
    // Actually the requirements say "Agreement = Yes".
    // Initially false.
    // We need to distinguish between "Not selected yet" and "Selected No".
    // But simplest is just boolean. If false, users can't proceed.
    // However, user wants explicit options: Yes, I agree / No, I don't agree.
    // So we can map true -> Yes, false -> No (or not selected).

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes, I agree',style: TextStyle(
            fontSize: 12, 
          ),),
                      value: true,
                      groupValue: value
                          ? true
                          : null, // If false, it might be unselected or explicit No.
                      // To simplify, let's assume default is false (No/Unselected).
                      // Wait, if separate states are needed, we need a nullable bool or int.
                      // But props are bool. Let's assume false = No/Unset.
                      // To support explicit "No" selection UI, we need local state if props are strictly bool.
                      // But props come from parent state.
                      // Let's stick to true = Yes, false = No/Unset.
                      onChanged: widget.enabled
                          ? (v) {
                              onChanged(v!);
                              if (!_showErrors)
                                setState(() => _showErrors = true);
                              _validate();
                            }
                          : null,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.success,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No, I don\'t agree',style: TextStyle(
            fontSize: 12, 
          ),),
                      value: false,
                      groupValue: !value ? false : null,
                      onChanged: widget.enabled
                          ? (v) {
                              onChanged(v!);
                              if (!_showErrors)
                                setState(() => _showErrors = true);
                              _validate();
                            }
                          : null,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              if (!value &&
                  _showErrors) // Show warning if No is selected (or just not Yes when validating)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 13,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warningText ?? '',
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
          ),
        ),
      ],
    );
  }
}
