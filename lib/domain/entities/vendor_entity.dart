import 'dart:io';

import 'package:equatable/equatable.dart';

class VendorEntity extends Equatable {
  // Personal Details
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final File? aadhaarFrontImage; // Id Proof Image file
  final File? aadhaarBackImage; // Id Proof Back Image file
  final String signname; // Signature name
  final String adharnumber; // Aadhaar number
  final String residentaladdress; // Residential address

  // Business Details
  final String businessName;
  final String businessEmail;
  final String altMobile;
  final String address;
  final List<String> categories;
  final String bussinessmobile;
  final String bussinesslegalname; // Business legal name

  // Document Details
  final List<String> docNames;
  final List<String> docIds;
  final List<String> documentNumbers;
  final List<String> expiryDates;
  final List<File?> files;

  // Image Fields for Vendor Creation (Multipart Arrays)
  final List<File> frontimages; // frontImage[] array
  final List<File> backimages; // backImage[] array
  final List<File> signature; // signature[] array
  final File? storeLogo;
  final File? profileBanner;

  // Banking Information
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

  // OTP for verification
  final String? otp;

  // ID Proof Type
  final String? proofType;

  // Location
  final double? latitude;
  final double? longitude;

  // Response fields (optional, populated after creation)
  final String? vendorId;
  final bool consentAccepted;
  final bool pricingAgreementAccepted;
  final bool slvAgreementAccepted;
  final bool? success;
  final String? message;

  // Verification Status Fields (for rejection highlighting)
  final String?
  verifyStatus; // Overall vendor status: "approved", "rejected", "pending", "processing"
  final String? adhaarfrontimagestatus; // Aadhaar front image status
  final String? adhaarbackimagestatus; // Aadhaar back image status
  final String? signatureStatus; // Signature status
  final List<Map<String, dynamic>>?
  documentStatuses; // Per-document verification info

  // Image URLs (for Edit Mode)
  final String? aadhaarFrontImageUrl;
  final String? aadhaarBackImageUrl;
  final List<String> docUrls;
  final List<String> frontImageUrls;
  final List<String> backImageUrls;
  final String? signatureImageUrl;
  final String? storeLogoUrl;
  final String? profileBannerUrl;

  const VendorEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.aadhaarFrontImageUrl,
    this.aadhaarBackImageUrl,
    this.signname = '',
    this.adharnumber = '',
    this.residentaladdress = '',
    this.proofType,
    required this.businessName,
    required this.businessEmail,
    required this.altMobile,
    required this.address,
    this.latitude,
    this.longitude,
    required this.categories,
    required this.bussinessmobile,
    this.bussinesslegalname = '',
    required this.docNames,
    required this.docIds,
    required this.documentNumbers,
    required this.expiryDates,
    required this.files,
    this.docUrls = const [],
    required this.frontimages,
    this.frontImageUrls = const [],
    required this.backimages,
    this.backImageUrls = const [],
    required this.signature,
    this.signatureImageUrl,
    this.storeLogo,
    this.storeLogoUrl,
    this.profileBanner,
    this.profileBannerUrl,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
    this.otp,
    this.vendorId,
    this.consentAccepted = false,
    this.pricingAgreementAccepted = false,
    this.slvAgreementAccepted = false,
    this.success,
    this.message,
    this.verifyStatus,
    this.adhaarfrontimagestatus,
    this.adhaarbackimagestatus,
    this.signatureStatus,
    this.documentStatuses,
  });

  VendorEntity copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? mobile,
    File? aadhaarFrontImage,
    File? aadhaarBackImage,
    String? aadhaarFrontImageUrl,
    String? aadhaarBackImageUrl,
    String? signname,
    String? adharnumber,
    String? residentaladdress,
    String? proofType,
    String? businessName,
    String? businessEmail,
    String? altMobile,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? categories,
    String? bussinessmobile,
    String? bussinesslegalname,
    List<String>? docNames,
    List<String>? docIds,
    List<String>? documentNumbers,
    List<String>? expiryDates,
    List<File?>? files,
    List<String>? docUrls,
    List<File>? frontimages,
    List<String>? frontImageUrls,
    List<File>? backimages,
    List<String>? backImageUrls,
    List<File>? signature,
    String? signatureImageUrl,
    File? storeLogo,
    String? storeLogoUrl,
    File? profileBanner,
    String? profileBannerUrl,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? otp,
    String? vendorId,
    bool? consentAccepted,
    bool? pricingAgreementAccepted,
    bool? slvAgreementAccepted,
    bool? success,
    String? message,
    String? verifyStatus,
    String? adhaarfrontimagestatus,
    String? adhaarbackimagestatus,
    String? signatureStatus,
    List<Map<String, dynamic>>? documentStatuses,
  }) {
    return VendorEntity(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      aadhaarFrontImage: aadhaarFrontImage ?? this.aadhaarFrontImage,
      aadhaarBackImage: aadhaarBackImage ?? this.aadhaarBackImage,
      aadhaarFrontImageUrl: aadhaarFrontImageUrl ?? this.aadhaarFrontImageUrl,
      aadhaarBackImageUrl: aadhaarBackImageUrl ?? this.aadhaarBackImageUrl,
      signname: signname ?? this.signname,
      adharnumber: adharnumber ?? this.adharnumber,
      residentaladdress: residentaladdress ?? this.residentaladdress,
      proofType: proofType ?? this.proofType,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      altMobile: altMobile ?? this.altMobile,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categories: categories ?? this.categories,
      bussinessmobile: bussinessmobile ?? this.bussinessmobile,
      bussinesslegalname: bussinesslegalname ?? this.bussinesslegalname,
      docNames: docNames ?? this.docNames,
      docIds: docIds ?? this.docIds,
      documentNumbers: documentNumbers ?? this.documentNumbers,
      expiryDates: expiryDates ?? this.expiryDates,
      files: files ?? this.files,
      docUrls: docUrls ?? this.docUrls,
      frontimages: frontimages ?? this.frontimages,
      frontImageUrls: frontImageUrls ?? this.frontImageUrls,
      backimages: backimages ?? this.backimages,
      backImageUrls: backImageUrls ?? this.backImageUrls,
      signature: signature ?? this.signature,
      signatureImageUrl: signatureImageUrl ?? this.signatureImageUrl,
      storeLogo: storeLogo ?? this.storeLogo,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      profileBanner: profileBanner ?? this.profileBanner,
      profileBannerUrl: profileBannerUrl ?? this.profileBannerUrl,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      otp: otp ?? this.otp,
      vendorId: vendorId ?? this.vendorId,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      pricingAgreementAccepted:
          pricingAgreementAccepted ?? this.pricingAgreementAccepted,
      slvAgreementAccepted: slvAgreementAccepted ?? this.slvAgreementAccepted,
      success: success ?? this.success,
      message: message ?? this.message,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      adhaarfrontimagestatus:
          adhaarfrontimagestatus ?? this.adhaarfrontimagestatus,
      adhaarbackimagestatus:
          adhaarbackimagestatus ?? this.adhaarbackimagestatus,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      documentStatuses: documentStatuses ?? this.documentStatuses,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    mobile,
    aadhaarFrontImage,
    aadhaarBackImage,
    aadhaarFrontImageUrl,
    aadhaarBackImageUrl,
    signname,
    adharnumber,
    residentaladdress,
    proofType,
    businessName,
    businessEmail,
    altMobile,
    address,
    latitude,
    longitude,
    categories,
    bussinessmobile,
    bussinesslegalname,
    docNames,
    docIds,
    documentNumbers,
    expiryDates,
    files,
    docUrls,
    frontimages,
    frontImageUrls,
    backimages,
    backImageUrls,
    signature,
    signatureImageUrl,
    storeLogo,
    storeLogoUrl,
    profileBanner,
    profileBannerUrl,
    bankName,
    accountName,
    accountNumber,
    ifscCode,
    branchName,
    otp,
    vendorId,
    success,
    message,
    verifyStatus,
    adhaarfrontimagestatus,
    adhaarbackimagestatus,
    signatureStatus,
    documentStatuses,
  ];
}
