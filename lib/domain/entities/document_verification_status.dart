import 'package:equatable/equatable.dart';

/// Represents the verification status of a single document
class DocumentVerificationStatus extends Equatable {
  final String docId; // Document ID (e.g., "PAN", "GST", etc.)
  final String? isVerified; // "approved", "rejected", "pending", "processing"
  final String? rejectionReason; // Reason for rejection (if rejected)

  const DocumentVerificationStatus({
    required this.docId,
    this.isVerified,
    this.rejectionReason,
  });

  /// Check if this document is rejected
  bool get isRejected => isVerified?.toLowerCase() == 'rejected';

  /// Check if this document is approved
  bool get isApproved => isVerified?.toLowerCase() == 'approved';

  /// Check if this document is pending
  bool get isPending =>
      isVerified?.toLowerCase() == 'pending' ||
      isVerified?.toLowerCase() == 'processing';

  @override
  List<Object?> get props => [docId, isVerified, rejectionReason];
}
