import 'package:equatable/equatable.dart';

/// Entity representing a draft vendor form
/// Stores serializable form data without File objects (uses file paths instead)
class DraftVendorEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int currentSectionIndex;

  // Personal Details
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String aadhaarNumber;
  final String? idProofType;
  final String residentialAddress;
  final String? aadhaarFrontImagePath;
  final String? aadhaarBackImagePath;

  // Business Details
  final String businessName;
  final String businessLegalName;
  final String businessEmail;
  final String businessMobile;
  final String altBusinessMobile;
  final String businessAddress;
  final List<String> categories; // Category IDs or names

  // Banking Details
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String bankName;
  final String bankBranch;

  // Documents
  final String panCardNumber;
  final String? panCardFilePath;
  final String? panCardExpiryDate;
  final String gstCertificateNumber;
  final String? gstCertificateFilePath;
  final String? gstExpiryDate;
  final String businessRegistrationNumber;
  final String? businessRegistrationFilePath;
  final String? businessRegistrationExpiryDate;
  final String professionalLicenseNumber;
  final String? professionalLicenseFilePath;
  final String? professionalLicenseExpiryDate;
  final String additionalDocumentName;
  final String? additionalDocumentFilePath;
  final String? additionalDocumentExpiryDate;

  // Photos - store paths as List<String>
  final List<String> frontStoreImagePaths;
  final String? storeLogoPath;
  final String? profileBannerPath;

  // Signature
  final String? signatureImagePath;
  final String? signerName;
  final bool acceptedTerms;
  final bool consentAccepted;
  final bool pricingAgreementAccepted;
  final bool slvAgreementAccepted;

  // Section completion status
  final List<bool> sectionCompleted;
  final List<bool> sectionValidations;

  const DraftVendorEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.currentSectionIndex,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.mobile = '',
    this.aadhaarNumber = '',
    this.idProofType,
    this.residentialAddress = '',
    this.aadhaarFrontImagePath,
    this.aadhaarBackImagePath,
    this.businessName = '',
    this.businessLegalName = '',
    this.businessEmail = '',
    this.businessMobile = '',
    this.altBusinessMobile = '',
    this.businessAddress = '',
    this.categories = const [],
    this.accountNumber = '',
    this.accountHolderName = '',
    this.ifscCode = '',
    this.bankName = '',
    this.bankBranch = '',
    this.panCardNumber = '',
    this.panCardFilePath,
    this.panCardExpiryDate,
    this.gstCertificateNumber = '',
    this.gstCertificateFilePath,
    this.gstExpiryDate,
    this.businessRegistrationNumber = '',
    this.businessRegistrationFilePath,
    this.businessRegistrationExpiryDate,
    this.professionalLicenseNumber = '',
    this.professionalLicenseFilePath,
    this.professionalLicenseExpiryDate,
    this.additionalDocumentName = '',
    this.additionalDocumentFilePath,
    this.additionalDocumentExpiryDate,
    this.frontStoreImagePaths = const [],
    this.storeLogoPath,
    this.profileBannerPath,
    this.signatureImagePath,
    this.signerName,
    this.acceptedTerms = false,
    this.consentAccepted = false,
    this.pricingAgreementAccepted = false,
    this.slvAgreementAccepted = false,
    this.sectionCompleted = const [false, false, false, false, false, false],
    this.sectionValidations = const [false, false, false, false, false, false],
  });

  /// Check if at least one field is filled (required for draft saving)
  bool get hasAnyData {
    return firstName.isNotEmpty ||
        lastName.isNotEmpty ||
        email.isNotEmpty ||
        mobile.isNotEmpty ||
        businessName.isNotEmpty ||
        businessEmail.isNotEmpty ||
        businessMobile.isNotEmpty ||
        accountNumber.isNotEmpty ||
        accountHolderName.isNotEmpty ||
        panCardNumber.isNotEmpty ||
        gstCertificateNumber.isNotEmpty ||
        frontStoreImagePaths.isNotEmpty ||
        consentAccepted ||
        pricingAgreementAccepted ||
        slvAgreementAccepted;
  }

  /// Get a preview title for the draft (vendor name or mobile number)
  String get previewTitle {
    if (businessName.isNotEmpty) return businessName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    if (businessMobile.isNotEmpty) return businessMobile;
    if (mobile.isNotEmpty) return mobile;
    return 'Untitled Draft';
  }

  /// Get a preview subtitle for the draft (mobile number or email)
  String get previewSubtitle {
    if (businessMobile.isNotEmpty) return businessMobile;
    if (mobile.isNotEmpty) return mobile;
    if (email.isNotEmpty) return email;
    if (businessEmail.isNotEmpty) return businessEmail;
    return '';
  }

  DraftVendorEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentSectionIndex,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    String? aadhaarNumber,
    String? idProofType,
    String? residentialAddress,
    String? aadhaarFrontImagePath,
    String? aadhaarBackImagePath,
    String? businessName,
    String? businessLegalName,
    String? businessEmail,
    String? businessMobile,
    String? altBusinessMobile,
    String? businessAddress,
    List<String>? categories,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    String? bankName,
    String? bankBranch,
    String? panCardNumber,
    String? panCardFilePath,
    String? panCardExpiryDate,
    String? gstCertificateNumber,
    String? gstCertificateFilePath,
    String? gstExpiryDate,
    String? businessRegistrationNumber,
    String? businessRegistrationFilePath,
    String? businessRegistrationExpiryDate,
    String? professionalLicenseNumber,
    String? professionalLicenseFilePath,
    String? professionalLicenseExpiryDate,
    String? additionalDocumentName,
    String? additionalDocumentFilePath,
    String? additionalDocumentExpiryDate,
    List<String>? frontStoreImagePaths,
    String? storeLogoPath,
    String? profileBannerPath,
    String? signatureImagePath,
    String? signerName,
    bool? acceptedTerms,
    bool? consentAccepted,
    bool? pricingAgreementAccepted,
    bool? slvAgreementAccepted,
    List<bool>? sectionCompleted,
    List<bool>? sectionValidations,
  }) {
    return DraftVendorEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      idProofType: idProofType ?? this.idProofType,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      aadhaarFrontImagePath:
          aadhaarFrontImagePath ?? this.aadhaarFrontImagePath,
      aadhaarBackImagePath: aadhaarBackImagePath ?? this.aadhaarBackImagePath,
      businessName: businessName ?? this.businessName,
      businessLegalName: businessLegalName ?? this.businessLegalName,
      businessEmail: businessEmail ?? this.businessEmail,
      businessMobile: businessMobile ?? this.businessMobile,
      altBusinessMobile: altBusinessMobile ?? this.altBusinessMobile,
      businessAddress: businessAddress ?? this.businessAddress,
      categories: categories ?? this.categories,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      panCardNumber: panCardNumber ?? this.panCardNumber,
      panCardFilePath: panCardFilePath ?? this.panCardFilePath,
      panCardExpiryDate: panCardExpiryDate ?? this.panCardExpiryDate,
      gstCertificateNumber: gstCertificateNumber ?? this.gstCertificateNumber,
      gstCertificateFilePath:
          gstCertificateFilePath ?? this.gstCertificateFilePath,
      gstExpiryDate: gstExpiryDate ?? this.gstExpiryDate,
      businessRegistrationNumber:
          businessRegistrationNumber ?? this.businessRegistrationNumber,
      businessRegistrationFilePath:
          businessRegistrationFilePath ?? this.businessRegistrationFilePath,
      businessRegistrationExpiryDate:
          businessRegistrationExpiryDate ?? this.businessRegistrationExpiryDate,
      professionalLicenseNumber:
          professionalLicenseNumber ?? this.professionalLicenseNumber,
      professionalLicenseFilePath:
          professionalLicenseFilePath ?? this.professionalLicenseFilePath,
      professionalLicenseExpiryDate:
          professionalLicenseExpiryDate ?? this.professionalLicenseExpiryDate,
      additionalDocumentName:
          additionalDocumentName ?? this.additionalDocumentName,
      additionalDocumentFilePath:
          additionalDocumentFilePath ?? this.additionalDocumentFilePath,
      additionalDocumentExpiryDate:
          additionalDocumentExpiryDate ?? this.additionalDocumentExpiryDate,
      frontStoreImagePaths: frontStoreImagePaths ?? this.frontStoreImagePaths,
      storeLogoPath: storeLogoPath ?? this.storeLogoPath,
      profileBannerPath: profileBannerPath ?? this.profileBannerPath,
      signatureImagePath: signatureImagePath ?? this.signatureImagePath,
      signerName: signerName ?? this.signerName,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      pricingAgreementAccepted:
          pricingAgreementAccepted ?? this.pricingAgreementAccepted,
      slvAgreementAccepted: slvAgreementAccepted ?? this.slvAgreementAccepted,
      sectionCompleted: sectionCompleted ?? this.sectionCompleted,
      sectionValidations: sectionValidations ?? this.sectionValidations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    currentSectionIndex,
    firstName,
    lastName,
    email,
    mobile,
    aadhaarNumber,
    idProofType,
    residentialAddress,
    aadhaarFrontImagePath,
    aadhaarBackImagePath,
    businessName,
    businessLegalName,
    businessEmail,
    businessMobile,
    altBusinessMobile,
    businessAddress,
    categories,
    accountNumber,
    accountHolderName,
    ifscCode,
    bankName,
    bankBranch,
    panCardNumber,
    panCardFilePath,
    panCardExpiryDate,
    gstCertificateNumber,
    gstCertificateFilePath,
    gstExpiryDate,
    businessRegistrationNumber,
    businessRegistrationFilePath,
    businessRegistrationExpiryDate,
    professionalLicenseNumber,
    professionalLicenseFilePath,
    professionalLicenseExpiryDate,
    additionalDocumentName,
    additionalDocumentFilePath,
    additionalDocumentExpiryDate,
    frontStoreImagePaths,
    storeLogoPath,
    profileBannerPath,
    signatureImagePath,
    signerName,
    acceptedTerms,
    consentAccepted,
    pricingAgreementAccepted,
    slvAgreementAccepted,
    sectionCompleted,
    sectionValidations,
  ];
}
