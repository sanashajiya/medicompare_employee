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
    super.mobile,
    super.aadhaarNumber,
    super.idProofType,
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
    super.panCardExpiryDate,
    super.gstCertificateNumber,
    super.gstCertificateFilePath,
    super.gstExpiryDate,
    super.businessRegistrationNumber,
    super.businessRegistrationFilePath,
    super.businessRegistrationExpiryDate,
    super.professionalLicenseNumber,
    super.professionalLicenseFilePath,
    super.professionalLicenseExpiryDate,
    super.additionalDocumentName,
    super.additionalDocumentFilePath,
    super.additionalDocumentExpiryDate,
    super.additionalDocuments,
    super.frontStoreImagePaths,
    super.storeLogoPath,
    super.profileBannerPath,
    super.signatureImagePath,
    super.signerName,
    super.acceptedTerms,
    super.consentAccepted,
    super.pricingAgreementAccepted,
    super.slvAgreementAccepted,
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
      mobile: entity.mobile,
      aadhaarNumber: entity.aadhaarNumber,
      idProofType: entity.idProofType,
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
      panCardExpiryDate: entity.panCardExpiryDate,
      gstCertificateNumber: entity.gstCertificateNumber,
      gstCertificateFilePath: entity.gstCertificateFilePath,
      gstExpiryDate: entity.gstExpiryDate,
      businessRegistrationNumber: entity.businessRegistrationNumber,
      businessRegistrationFilePath: entity.businessRegistrationFilePath,
      businessRegistrationExpiryDate: entity.businessRegistrationExpiryDate,
      professionalLicenseNumber: entity.professionalLicenseNumber,
      professionalLicenseFilePath: entity.professionalLicenseFilePath,
      professionalLicenseExpiryDate: entity.professionalLicenseExpiryDate,
      additionalDocumentName: entity.additionalDocumentName,
      additionalDocumentFilePath: entity.additionalDocumentFilePath,
      additionalDocumentExpiryDate: entity.additionalDocumentExpiryDate,
      additionalDocuments: entity.additionalDocuments,
      frontStoreImagePaths: entity.frontStoreImagePaths,
      storeLogoPath: entity.storeLogoPath,
      profileBannerPath: entity.profileBannerPath,
      signatureImagePath: entity.signatureImagePath,
      signerName: entity.signerName,
      acceptedTerms: entity.acceptedTerms,
      consentAccepted: entity.consentAccepted,
      pricingAgreementAccepted: entity.pricingAgreementAccepted,
      slvAgreementAccepted: entity.slvAgreementAccepted,
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
      'mobile': mobile,
      'aadhaarNumber': aadhaarNumber,
      'idProofType': idProofType,
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
      'panCardExpiryDate': panCardExpiryDate,
      'gstCertificateNumber': gstCertificateNumber,
      'gstCertificateFilePath': gstCertificateFilePath,
      'gstExpiryDate': gstExpiryDate,
      'businessRegistrationNumber': businessRegistrationNumber,
      'businessRegistrationFilePath': businessRegistrationFilePath,
      'businessRegistrationExpiryDate': businessRegistrationExpiryDate,
      'professionalLicenseNumber': professionalLicenseNumber,
      'professionalLicenseFilePath': professionalLicenseFilePath,
      'professionalLicenseExpiryDate': professionalLicenseExpiryDate,
      'additionalDocumentName': additionalDocumentName,
      'additionalDocumentFilePath': additionalDocumentFilePath,
      'additionalDocumentExpiryDate': additionalDocumentExpiryDate,
      'additionalDocuments': additionalDocuments,
      'frontStoreImagePaths': frontStoreImagePaths,
      'storeLogoPath': storeLogoPath,
      'profileBannerPath': profileBannerPath,
      'signatureImagePath': signatureImagePath,
      'signerName': signerName,
      'acceptedTerms': acceptedTerms,
      'consentAccepted': consentAccepted,
      'pricingAgreementAccepted': pricingAgreementAccepted,
      'slvAgreementAccepted': slvAgreementAccepted,
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
      mobile: map['mobile'] as String? ?? '',
      aadhaarNumber:
          map['aadhaarNumber'] as String? ??
          map['aadhaarCardNumber'] as String? ??
          '',
      idProofType: map['idProofType'] as String?,
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
      panCardExpiryDate: map['panCardExpiryDate'] as String?,
      gstCertificateNumber: map['gstCertificateNumber'] as String? ?? '',
      gstCertificateFilePath: map['gstCertificateFilePath'] as String?,
      gstExpiryDate: map['gstExpiryDate'] as String?,
      businessRegistrationNumber:
          map['businessRegistrationNumber'] as String? ?? '',
      businessRegistrationFilePath:
          map['businessRegistrationFilePath'] as String?,
      businessRegistrationExpiryDate:
          map['businessRegistrationExpiryDate'] as String?,
      professionalLicenseNumber:
          map['professionalLicenseNumber'] as String? ?? '',
      professionalLicenseFilePath:
          map['professionalLicenseFilePath'] as String?,
      professionalLicenseExpiryDate:
          map['professionalLicenseExpiryDate'] as String?,
      additionalDocumentName: map['additionalDocumentName'] as String? ?? '',
      additionalDocumentFilePath: map['additionalDocumentFilePath'] as String?,
      additionalDocumentExpiryDate:
          map['additionalDocumentExpiryDate'] as String?,
      additionalDocuments:
          (map['additionalDocuments'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      frontStoreImagePaths:
          (map['frontStoreImagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      storeLogoPath: map['storeLogoPath'] as String?,
      profileBannerPath: map['profileBannerPath'] as String?,
      signatureImagePath: map['signatureImagePath'] as String?,
      signerName: map['signerName'] as String? ?? map['signName'] as String?,
      acceptedTerms: map['acceptedTerms'] as bool? ?? false,
      consentAccepted: map['consentAccepted'] as bool? ?? false,
      pricingAgreementAccepted:
          map['pricingAgreementAccepted'] as bool? ?? false,
      slvAgreementAccepted: map['slvAgreementAccepted'] as bool? ?? false,
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
