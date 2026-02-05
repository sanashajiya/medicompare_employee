import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_text_field.dart';

class SignatureSection extends StatefulWidget {
  final SignatureController signatureController;
  final TextEditingController signerNameController;
  final Uint8List? signatureBytes;
  final String? signatureImageUrl;
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
    this.signatureImageUrl,
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
  late final String agreementId;

  @override
  void initState() {
    super.initState();
    agreementId = _generateAgreementId();
    widget.signerNameController.addListener(_validate);
    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  @override
  void dispose() {
    widget.signerNameController.removeListener(_validate);
    super.dispose();
  }

  @override
  void didUpdateWidget(SignatureSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signatureBytes != widget.signatureBytes ||
        oldWidget.signatureImageUrl != widget.signatureImageUrl) {
      _validate();
    }
  }

  String _generateAgreementId() {
    final random = Random();
    return 'VA-${random.nextInt(900000) + 100000}'; // 6-digit random number
  }

  void _validate() {
    final hasSignature =
        widget.signatureBytes != null ||
        (widget.signatureImageUrl != null &&
            widget.signatureImageUrl!.isNotEmpty);

    final isValid =
        widget.signerNameController.text.trim().isNotEmpty &&
        hasSignature &&
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
    final hasSignature =
        widget.signatureBytes != null ||
        (widget.signatureImageUrl != null &&
            widget.signatureImageUrl!.isNotEmpty);

    setState(() {
      _signerNameError = widget.signerNameController.text.trim().isEmpty
          ? 'Signer name is required'
          : null;
      _signatureError = !hasSignature
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
    // If we have a remote image URL but no local bytes, we might want to try fetching the bytes
    // to embed in the PDF, or just use a placeholder.
    Uint8List? signatureForPdf = widget.signatureBytes;

    if (signatureForPdf == null && widget.signatureImageUrl != null) {
      try {
        final response = await http.get(Uri.parse(widget.signatureImageUrl!));
        if (response.statusCode == 200) {
          signatureForPdf = response.bodyBytes;
        }
      } catch (e) {
        debugPrint('Failed to download signature for PDF: $e');
      }
    }

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
              pw.Text('Date: ${_formatDate(DateTime.now())}'),
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
                  if (signatureForPdf != null)
                    pw.Image(
                      pw.MemoryImage(signatureForPdf!),
                      width: 100,
                      height: 50,
                    )
                  else
                    pw.Text('[Digital Signature on File]'),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'This is a computer-generated agreement. No physical signature is required.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                '© 2026 MediCompares. All rights reserved.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agreement generated at ${file.path}')),
        );
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to generate PDF')));
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vendor Agreement Preview',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agreement ID: $agreementId',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton.icon(
                            onPressed: _generateAndOpenPdf,
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Download Agreement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      // direction: Axis.vertical,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Agreement Title
                        const Center(
                          child: Text(
                            'VENDOR AGREEMENT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Agreement Text
                        const Text(
                          'This agreement confirms that the vendor has accepted all terms and conditions, pricing models, and service level agreements (SLVs) as stipulated by the platform.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Signer Name Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Signed for and on behalf of the Vendor',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.signerNameController.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Digital Signature Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: (widget.signatureBytes != null)
                                    ? Image.memory(
                                        widget.signatureBytes!,
                                        height: 80,
                                        fit: BoxFit.contain,
                                      )
                                    : (widget.signatureImageUrl != null)
                                    ? Image.network(
                                        widget.signatureImageUrl!,
                                        height: 80,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text('[Signature Error]'),
                                      )
                                    : const SizedBox(height: 80, width: 200),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '[Digital Signature]',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Date Section
                        Text(
                          'Date: ${_formatDate(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 48),
                        Divider(color: Colors.grey.withOpacity(0.2)),
                        const SizedBox(height: 16),

                        // Footer
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'This is a computer-generated agreement. No physical signature is required.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '© 2026 MediCompares. All rights reserved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final hasSignature =
        widget.signatureBytes != null ||
        (widget.signatureImageUrl != null &&
            widget.signatureImageUrl!.isNotEmpty);

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
        if (hasSignature) ...[
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
                      'Saved Signature',
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
                    child: widget.signatureBytes != null
                        ? Image.memory(
                            widget.signatureBytes!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error_outline)),
                          )
                        : Image.network(
                            widget.signatureImageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image)),
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
        ],

        // Signature Pad - Only show if NO signature is saved
        if (!hasSignature) ...[
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
        if (hasSignature)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton.icon(
                onPressed: widget.enabled
                    ? () {
                        // Enter edit mode by clearing signature (but be careful if it was URL)
                        // If we clear signature, the URL is cleared from view effectively because hasSignature becomes false
                        // WE need to clear the URL in the parent too?
                        // Or just clearing locally allows redraw, and when saved it provides bytes which override URL.
                        // But wait, the URL comes from Widget props. We can't clear it.
                        // The 'hasSignature' check uses widget.signatureImageUrl.
                        // If I click clear, I need the parent to set signatureImageUrl to null.
                        // But I don't have a callback for that.
                        // I currently only have `onSignatureSaved(Uint8List?)`.
                        // Assumptions: passing null to onSignatureSaved should signal "clear everything".
                        // In VendorProfileScreen, onSignatureSaved(null) should ALSO clear the signatureImageUrl state.
                        _clearSignature();
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

        const SizedBox(height: 32),

        // Agreement Preview Button
        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton.icon(
        //     onPressed: (hasSignature || widget.signatureImageUrl != null)
        //         ? _showPreviewDialog
        //         : null,
        //     icon: const Icon(Icons.visibility_outlined),
        //     label: const Text('Preview Vendor Agreement'),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       foregroundColor: AppColors.primary,
        //       side: const BorderSide(color: AppColors.primary),
        //     ),
        //   ),
        // ),

        // const SizedBox(height: 32),
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
              'You must agree to the pricing terms to proceed with registration.',
        ),

        const SizedBox(height: 24),

        // SLV Agreement
        _buildRadioSection(
          title: 'Service Level Agreement (SLV) *',
          question:
              'Do you commit to adhering to the Service Level Agreement (SLV), ensuring timely and quality service delivery?',
          value: widget.slvAgreementAccepted,
          onChanged: widget.onSlvAgreementChanged,
          errorText: _showErrors ? _slvError : null,
          warningText:
              'Acceptance of the SLV is mandatory to ensure quality standards.',
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
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
                      ? (v) => onChanged(v ?? false)
                      : null,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
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
    required String warningText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRadioButton(
                    label: 'Yes, I Agree',
                    value: true,
                    groupValue: value,
                    onChanged: onChanged,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 16),
                  _buildRadioButton(
                    label: 'No',
                    value: false,
                    groupValue: value,
                    onChanged: onChanged,
                    color: AppColors.error,
                  ),
                ],
              ),
              if (!value && errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          warningText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
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

  Widget _buildRadioButton({
    required String label,
    required bool value,
    required bool groupValue,
    required Function(bool) onChanged,
    required Color color,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: widget.enabled ? () => onChanged(value) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.textSecondary,
                  width: 1.5,
                ),
                color: isSelected ? color : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
