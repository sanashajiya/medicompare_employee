import 'package:equatable/equatable.dart';
import 'vendor_entity.dart';

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
  final String password;
  final String mobile;
  final String aadhaarNumber;
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
  final String gstCertificateNumber;
  final String? gstCertificateFilePath;
  final String businessRegistrationNumber;
  final String? businessRegistrationFilePath;
  final String professionalLicenseNumber;
  final String? professionalLicenseFilePath;
  final String additionalDocumentName;
  final String? additionalDocumentFilePath;

  // Photos - store paths as List<String>
  final List<String> frontStoreImagePaths;

  // Signature
  final String? signatureImagePath;
  final String? signerName;
  final bool acceptedTerms;

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
    this.password = '',
    this.mobile = '',
    this.aadhaarNumber = '',
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
    this.gstCertificateNumber = '',
    this.gstCertificateFilePath,
    this.businessRegistrationNumber = '',
    this.businessRegistrationFilePath,
    this.professionalLicenseNumber = '',
    this.professionalLicenseFilePath,
    this.additionalDocumentName = '',
    this.additionalDocumentFilePath,
    this.frontStoreImagePaths = const [],
    this.signatureImagePath,
    this.signerName,
    this.acceptedTerms = false,
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
        frontStoreImagePaths.isNotEmpty;
  }

  /// Get a preview title for the draft (vendor name or mobile number)
  String get previewTitle {
    if (businessName.isNotEmpty) return businessName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '${firstName} ${lastName}'.trim();
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
    String? password,
    String? mobile,
    String? aadhaarNumber,
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
    String? gstCertificateNumber,
    String? gstCertificateFilePath,
    String? businessRegistrationNumber,
    String? businessRegistrationFilePath,
    String? professionalLicenseNumber,
    String? professionalLicenseFilePath,
    String? additionalDocumentName,
    String? additionalDocumentFilePath,
    List<String>? frontStoreImagePaths,
    String? signatureImagePath,
    String? signerName,
    bool? acceptedTerms,
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
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
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
      gstCertificateNumber: gstCertificateNumber ?? this.gstCertificateNumber,
      gstCertificateFilePath:
          gstCertificateFilePath ?? this.gstCertificateFilePath,
      businessRegistrationNumber:
          businessRegistrationNumber ?? this.businessRegistrationNumber,
      businessRegistrationFilePath:
          businessRegistrationFilePath ?? this.businessRegistrationFilePath,
      professionalLicenseNumber:
          professionalLicenseNumber ?? this.professionalLicenseNumber,
      professionalLicenseFilePath:
          professionalLicenseFilePath ?? this.professionalLicenseFilePath,
      additionalDocumentName:
          additionalDocumentName ?? this.additionalDocumentName,
      additionalDocumentFilePath:
          additionalDocumentFilePath ?? this.additionalDocumentFilePath,
      frontStoreImagePaths: frontStoreImagePaths ?? this.frontStoreImagePaths,
      signatureImagePath: signatureImagePath ?? this.signatureImagePath,
      signerName: signerName ?? this.signerName,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
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
    password,
    mobile,
    aadhaarNumber,
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
    gstCertificateNumber,
    gstCertificateFilePath,
    businessRegistrationNumber,
    businessRegistrationFilePath,
    professionalLicenseNumber,
    professionalLicenseFilePath,
    additionalDocumentName,
    additionalDocumentFilePath,
    frontStoreImagePaths,
    signatureImagePath,
    signerName,
    acceptedTerms,
    sectionCompleted,
    sectionValidations,
  ];
}




