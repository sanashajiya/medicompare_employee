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

  const VendorEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
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
    required this.frontimages,
    required this.backimages,
    required this.signature,
    this.storeLogo,
    this.profileBanner,
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
  });

  VendorEntity copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? mobile,
    File? aadhaarFrontImage,
    File? aadhaarBackImage,
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
    List<File>? frontimages,
    List<File>? backimages,
    List<File>? signature,
    File? storeLogo,
    File? profileBanner,
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
  }) {
    return VendorEntity(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      aadhaarFrontImage: aadhaarFrontImage ?? this.aadhaarFrontImage,
      aadhaarBackImage: aadhaarBackImage ?? this.aadhaarBackImage,
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
      frontimages: frontimages ?? this.frontimages,
      backimages: backimages ?? this.backimages,
      signature: signature ?? this.signature,
      storeLogo: storeLogo ?? this.storeLogo,
      profileBanner: profileBanner ?? this.profileBanner,
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
    frontimages,
    backimages,
    signature,
    storeLogo,
    profileBanner,
    bankName,
    accountName,
    accountNumber,
    ifscCode,
    branchName,
    otp,
    vendorId,
    success,
    message,
  ];
}
