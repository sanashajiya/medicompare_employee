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
