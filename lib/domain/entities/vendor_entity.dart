import 'dart:io';
import 'package:equatable/equatable.dart';

class VendorEntity extends Equatable {
  // Personal Details
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final File? aadhaarFrontImage; // Govt Id Proof Image file
  final File? aadhaarBackImage; // Govt Id Proof Back Image file
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
  final List<File?> files;

  // Image Fields for Vendor Creation (Multipart Arrays)
  final List<File> frontimages; // frontImage[] array
  final List<File> backimages; // backImage[] array
  final List<File> signature; // signature[] array

  // Banking Information
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

  // OTP for verification
  final String? otp;

  // Response fields (optional, populated after creation)
  final String? vendorId;
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
    required this.businessName,
    required this.businessEmail,
    required this.altMobile,
    required this.address,
    required this.categories,
    required this.bussinessmobile,
    this.bussinesslegalname = '',
    required this.docNames,
    required this.docIds,
    required this.documentNumbers,
    required this.files,
    required this.frontimages,
    required this.backimages,
    required this.signature,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
    this.otp,
    this.vendorId,
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
    String? businessName,
    String? businessEmail,
    String? altMobile,
    String? address,
    List<String>? categories,
    String? bussinessmobile,
    String? bussinesslegalname,
    List<String>? docNames,
    List<String>? docIds,
    List<String>? documentNumbers,
    List<File?>? files,
    List<File>? frontimages,
    List<File>? backimages,
    List<File>? signature,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? otp,
    String? vendorId,
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
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      altMobile: altMobile ?? this.altMobile,
      address: address ?? this.address,
      categories: categories ?? this.categories,
      bussinessmobile: bussinessmobile ?? this.bussinessmobile,
      bussinesslegalname: bussinesslegalname ?? this.bussinesslegalname,
      docNames: docNames ?? this.docNames,
      docIds: docIds ?? this.docIds,
      documentNumbers: documentNumbers ?? this.documentNumbers,
      files: files ?? this.files,
      frontimages: frontimages ?? this.frontimages,
      backimages: backimages ?? this.backimages,
      signature: signature ?? this.signature,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      otp: otp ?? this.otp,
      vendorId: vendorId ?? this.vendorId,
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
    businessName,
    businessEmail,
    altMobile,
    address,
    categories,
    bussinessmobile,
    bussinesslegalname,
    docNames,
    docIds,
    documentNumbers,
    files,
    frontimages,
    backimages,
    signature,
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
