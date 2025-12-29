import '../../domain/entities/vendor_list_item_entity.dart';

class VendorListItemModel extends VendorListItemEntity {
  const VendorListItemModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.mobile,
    super.verifyStatus,
    super.vendorsId,
    super.businessName,
    super.businessEmail,
    super.createdAt,
    super.updatedAt,
    super.rawData,
  });

  factory VendorListItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return VendorListItemModel(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile']?.toString() ?? '',
      verifyStatus: json['verifyStatus'] as String?,
      vendorsId: json['vendorsId'] as String?,
      businessName: json['businessName'] as String?,
      businessEmail: json['businessEmail'] as String?,
      createdAt: parseDate(json['createdAt'] as String?),
      updatedAt: parseDate(json['updatedAt'] as String?),
      rawData: json, // Store the full vendor JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'verifyStatus': verifyStatus,
      'vendorsId': vendorsId,
      'businessName': businessName,
      'businessEmail': businessEmail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
