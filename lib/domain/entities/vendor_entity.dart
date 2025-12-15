import 'dart:io';
import 'package:equatable/equatable.dart';

class VendorEntity extends Equatable {
  // Personal Details
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;

  // Business Details
  final String businessName;
  final String businessEmail;
  final String altMobile;
  final String address;
  final List<String> categories;
  final String bussinessmobile;

  // Document Details
  final List<String> docNames;
  final List<String> docIds;
  final List<String> documentNumbers;
  final List<File?> files;

  // Banking Information
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

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
    required this.businessName,
    required this.businessEmail,
    required this.altMobile,
    required this.address,
    required this.categories,
    required this.bussinessmobile,
    required this.docNames,
    required this.docIds,
    required this.documentNumbers,
    required this.files,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
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
    String? businessName,
    String? businessEmail,
    String? altMobile,
    String? address,
    List<String>? categories,
    String? bussinessmobile,
    List<String>? docNames,
    List<String>? docIds,
    List<String>? documentNumbers,
    List<File?>? files,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
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
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      altMobile: altMobile ?? this.altMobile,
      address: address ?? this.address,
      categories: categories ?? this.categories,
      bussinessmobile: bussinessmobile ?? this.bussinessmobile,
      docNames: docNames ?? this.docNames,
      docIds: docIds ?? this.docIds,
      documentNumbers: documentNumbers ?? this.documentNumbers,
      files: files ?? this.files,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
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
        businessName,
        businessEmail,
        altMobile,
        address,
        categories,
        bussinessmobile,
        docNames,
        docIds,
        documentNumbers,
        files,
        bankName,
        accountName,
        accountNumber,
        ifscCode,
        branchName,
        vendorId,
        success,
        message,
      ];
}

