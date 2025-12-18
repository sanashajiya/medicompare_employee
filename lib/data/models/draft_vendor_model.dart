import '../../domain/entities/draft_vendor_entity.dart';

/// Model class for Hive storage
/// Converts between entity and JSON for Hive storage
class DraftVendorModel extends DraftVendorEntity {
  const DraftVendorModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.currentSectionIndex,
    super.firstName,
    super.lastName,
    super.email,
    super.password,
    super.mobile,
    super.aadhaarNumber,
    super.residentialAddress,
    super.aadhaarFrontImagePath,
    super.aadhaarBackImagePath,
    super.businessName,
    super.businessLegalName,
    super.businessEmail,
    super.businessMobile,
    super.altBusinessMobile,
    super.businessAddress,
    super.categories,
    super.accountNumber,
    super.accountHolderName,
    super.ifscCode,
    super.bankName,
    super.bankBranch,
    super.panCardNumber,
    super.panCardFilePath,
    super.gstCertificateNumber,
    super.gstCertificateFilePath,
    super.businessRegistrationNumber,
    super.businessRegistrationFilePath,
    super.professionalLicenseNumber,
    super.professionalLicenseFilePath,
    super.additionalDocumentName,
    super.additionalDocumentFilePath,
    super.frontStoreImagePaths,
    super.signatureImagePath,
    super.signerName,
    super.acceptedTerms,
    super.sectionCompleted,
    super.sectionValidations,
  });

  /// Convert entity to model
  factory DraftVendorModel.fromEntity(DraftVendorEntity entity) {
    return DraftVendorModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      currentSectionIndex: entity.currentSectionIndex,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
      mobile: entity.mobile,
      aadhaarNumber: entity.aadhaarNumber,
      residentialAddress: entity.residentialAddress,
      aadhaarFrontImagePath: entity.aadhaarFrontImagePath,
      aadhaarBackImagePath: entity.aadhaarBackImagePath,
      businessName: entity.businessName,
      businessLegalName: entity.businessLegalName,
      businessEmail: entity.businessEmail,
      businessMobile: entity.businessMobile,
      altBusinessMobile: entity.altBusinessMobile,
      businessAddress: entity.businessAddress,
      categories: entity.categories,
      accountNumber: entity.accountNumber,
      accountHolderName: entity.accountHolderName,
      ifscCode: entity.ifscCode,
      bankName: entity.bankName,
      bankBranch: entity.bankBranch,
      panCardNumber: entity.panCardNumber,
      panCardFilePath: entity.panCardFilePath,
      gstCertificateNumber: entity.gstCertificateNumber,
      gstCertificateFilePath: entity.gstCertificateFilePath,
      businessRegistrationNumber: entity.businessRegistrationNumber,
      businessRegistrationFilePath: entity.businessRegistrationFilePath,
      professionalLicenseNumber: entity.professionalLicenseNumber,
      professionalLicenseFilePath: entity.professionalLicenseFilePath,
      additionalDocumentName: entity.additionalDocumentName,
      additionalDocumentFilePath: entity.additionalDocumentFilePath,
      frontStoreImagePaths: entity.frontStoreImagePaths,
      signatureImagePath: entity.signatureImagePath,
      signerName: entity.signerName,
      acceptedTerms: entity.acceptedTerms,
      sectionCompleted: entity.sectionCompleted,
      sectionValidations: entity.sectionValidations,
    );
  }

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentSectionIndex': currentSectionIndex,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'mobile': mobile,
      'aadhaarNumber': aadhaarNumber,
      'residentialAddress': residentialAddress,
      'aadhaarFrontImagePath': aadhaarFrontImagePath,
      'aadhaarBackImagePath': aadhaarBackImagePath,
      'businessName': businessName,
      'businessLegalName': businessLegalName,
      'businessEmail': businessEmail,
      'businessMobile': businessMobile,
      'altBusinessMobile': altBusinessMobile,
      'businessAddress': businessAddress,
      'categories': categories,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'panCardNumber': panCardNumber,
      'panCardFilePath': panCardFilePath,
      'gstCertificateNumber': gstCertificateNumber,
      'gstCertificateFilePath': gstCertificateFilePath,
      'businessRegistrationNumber': businessRegistrationNumber,
      'businessRegistrationFilePath': businessRegistrationFilePath,
      'professionalLicenseNumber': professionalLicenseNumber,
      'professionalLicenseFilePath': professionalLicenseFilePath,
      'additionalDocumentName': additionalDocumentName,
      'additionalDocumentFilePath': additionalDocumentFilePath,
      'frontStoreImagePaths': frontStoreImagePaths,
      'signatureImagePath': signatureImagePath,
      'signerName': signerName,
      'acceptedTerms': acceptedTerms,
      'sectionCompleted': sectionCompleted,
      'sectionValidations': sectionValidations,
    };
  }

  /// Create from Map (from Hive storage)
  factory DraftVendorModel.fromMap(Map<String, dynamic> map) {
    return DraftVendorModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      currentSectionIndex: map['currentSectionIndex'] as int,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      aadhaarNumber: map['aadhaarNumber'] as String? ?? '',
      residentialAddress: map['residentialAddress'] as String? ?? '',
      // Backward compatibility: if old aadhaarPhotoPath exists, use it as front image
      aadhaarFrontImagePath:
          map['aadhaarFrontImagePath'] as String? ??
          map['aadhaarPhotoPath'] as String?,
      aadhaarBackImagePath: map['aadhaarBackImagePath'] as String?,
      businessName: map['businessName'] as String? ?? '',
      businessLegalName: map['businessLegalName'] as String? ?? '',
      businessEmail: map['businessEmail'] as String? ?? '',
      businessMobile: map['businessMobile'] as String? ?? '',
      altBusinessMobile: map['altBusinessMobile'] as String? ?? '',
      businessAddress: map['businessAddress'] as String? ?? '',
      categories:
          (map['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      accountNumber: map['accountNumber'] as String? ?? '',
      accountHolderName: map['accountHolderName'] as String? ?? '',
      ifscCode: map['ifscCode'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      bankBranch: map['bankBranch'] as String? ?? '',
      panCardNumber: map['panCardNumber'] as String? ?? '',
      panCardFilePath: map['panCardFilePath'] as String?,
      gstCertificateNumber: map['gstCertificateNumber'] as String? ?? '',
      gstCertificateFilePath: map['gstCertificateFilePath'] as String?,
      businessRegistrationNumber:
          map['businessRegistrationNumber'] as String? ?? '',
      businessRegistrationFilePath:
          map['businessRegistrationFilePath'] as String?,
      professionalLicenseNumber:
          map['professionalLicenseNumber'] as String? ?? '',
      professionalLicenseFilePath:
          map['professionalLicenseFilePath'] as String?,
      additionalDocumentName: map['additionalDocumentName'] as String? ?? '',
      additionalDocumentFilePath: map['additionalDocumentFilePath'] as String?,
      frontStoreImagePaths:
          (map['frontStoreImagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      signatureImagePath: map['signatureImagePath'] as String?,
      signerName: map['signerName'] as String?,
      acceptedTerms: map['acceptedTerms'] as bool? ?? false,
      sectionCompleted:
          (map['sectionCompleted'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [false, false, false, false, false, false],
      sectionValidations:
          (map['sectionValidations'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [false, false, false, false, false, false],
    );
  }
}
