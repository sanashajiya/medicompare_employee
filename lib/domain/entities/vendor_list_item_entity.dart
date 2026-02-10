import 'package:equatable/equatable.dart';

class VendorListItemEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String? verifyStatus; // 'pending' | 'approved' | 'rejected'
  final String? vendorsId;
  final String? businessName;
  final String? businessEmail;
  final String? rejectedReason; // Reason for rejection
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? rawData; // Store full vendor JSON for editing

  const VendorListItemEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    this.verifyStatus,
    this.vendorsId,
    this.businessName,
    this.businessEmail,
    this.rejectedReason,
    this.createdAt,
    this.updatedAt,
    this.rawData,
  });

  String get fullName => '$firstName $lastName';

  bool get isEffectiveRejected {
    final status = verifyStatus?.toLowerCase().trim();
    if (status == 'rejected') return true;
    if (status == 'approved') return false;

    // 2. Check isVerified flag
    if (rawData != null &&
        rawData!['isVerified'] == false &&
        rawData!['verifyStatus'] == 'rejected')
      return true;

    // 3. Check document statuses in rawData
    if (rawData != null) {
      // Top-level document statuses
      if (rawData!['adhaarfrontimagestatus'] == 'rejected') return true;
      if (rawData!['adhaarbackimagestatus'] == 'rejected') return true;

      // Nested documents object
      final documents = rawData!['documents'];
      if (documents is Map<String, dynamic>) {
        if (documents['frontImageStatus'] == 'rejected') return true;
        if (documents['signatureStatus'] == 'rejected') return true;
        if (documents['backimageStatus'] == 'rejected') return true;

        // Check documentsDetails array
        final docDetails = documents['documentsDetails'];
        if (docDetails is List) {
          for (var doc in docDetails) {
            if (doc is Map<String, dynamic>) {
              if (doc['isVerified'] == 'rejected') return true;
            }
          }
        }
      }
    }

    return false;
  }

  String get effectiveVerifyStatus {
    if (isEffectiveRejected) return 'rejected';
    return verifyStatus?.toLowerCase().trim() ?? 'pending';
  }

  String? get effectiveRejectionReason {
    if (rejectedReason != null && rejectedReason!.isNotEmpty)
      return rejectedReason;

    // Try to find a reason in documents if main reason is missing
    if (rawData != null) {
      // Check for specific document rejection reasons if needed,
      // but for now, we'll return a generic message if we found it was rejected based on documents
      if (isEffectiveRejected &&
          verifyStatus?.toLowerCase().trim() != 'rejected') {
        return "Some documents were rejected. Reupload to continue verification.";
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    mobile,
    verifyStatus,
    vendorsId,
    businessName,
    businessEmail,
    rejectedReason,
    createdAt,
    updatedAt,
    rawData,
  ];
}
