import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/entities/vendor_entity.dart';

class VendorModel extends VendorEntity {
  const VendorModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.password,
    required super.mobile,
    required super.businessName,
    required super.businessEmail,
    required super.altMobile,
    required super.address,
    required super.categories,
    required super.bussinessmobile,
    required super.docNames,
    required super.docIds,
    required super.documentNumbers,
    required super.files,
    required super.bankName,
    required super.accountName,
    required super.accountNumber,
    required super.ifscCode,
    required super.branchName,
    super.vendorId,
    super.success,
    super.message,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      mobile: json['mobile'] ?? '',
      businessName: json['businessName'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      altMobile: json['alt_mobile'] ?? '',
      address: json['address'] ?? '',
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      bussinessmobile: json['bussinessmobile'] ?? '',
      docNames: json['doc_name'] != null 
          ? List<String>.from(json['doc_name']) 
          : [],
      docIds: json['doc_id'] != null 
          ? List<String>.from(json['doc_id']) 
          : [],
      documentNumbers: json['documentNumber'] != null 
          ? List<String>.from(json['documentNumber']) 
          : [],
      files: [],
      bankName: json['bankName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branchName: json['branchName'] ?? '',
      vendorId: json['vendorId'],
      success: json['success'],
      message: json['message'],
    );
  }

  factory VendorModel.fromEntity(VendorEntity entity) {
    return VendorModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
      mobile: entity.mobile,
      businessName: entity.businessName,
      businessEmail: entity.businessEmail,
      altMobile: entity.altMobile,
      address: entity.address,
      categories: entity.categories,
      bussinessmobile: entity.bussinessmobile,
      docNames: entity.docNames,
      docIds: entity.docIds,
      documentNumbers: entity.documentNumbers,
      files: entity.files,
      bankName: entity.bankName,
      accountName: entity.accountName,
      accountNumber: entity.accountNumber,
      ifscCode: entity.ifscCode,
      branchName: entity.branchName,
      vendorId: entity.vendorId,
      success: entity.success,
      message: entity.message,
    );
  }

  /// Convert to multipart request fields
  Future<Map<String, String>> toMultipartFields() async {
    final fields = <String, String>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'mobile': mobile,
      'businessName': businessName,
      'businessEmail': businessEmail,
      'alt_mobile': altMobile,
      'address': address,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'bussinessmobile': bussinessmobile,
    };

    // Add array fields - categories should contain ObjectIds, not names
    for (var i = 0; i < categories.length; i++) {
      fields['categoryIds[$i]'] = categories[i];
    }

    for (var i = 0; i < docNames.length; i++) {
      fields['doc_name[$i]'] = docNames[i];
    }

    for (var i = 0; i < docIds.length; i++) {
      fields['doc_id[$i]'] = docIds[i];
    }

    for (var i = 0; i < documentNumbers.length; i++) {
      fields['documentNumber[$i]'] = documentNumbers[i];
    }

    return fields;
  }

  /// Get multipart files with proper content types
  Future<List<http.MultipartFile>> toMultipartFiles() async {
    final multipartFiles = <http.MultipartFile>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      if (file != null && await file.exists()) {
        // Determine MIME type based on file extension
        final extension = file.path.split('.').last.toLowerCase();
        String contentType = 'application/octet-stream';
        
        switch (extension) {
          case 'pdf':
            contentType = 'application/pdf';
            break;
          case 'doc':
            contentType = 'application/msword';
            break;
          case 'docx':
            contentType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            break;
          case 'xls':
            contentType = 'application/vnd.ms-excel';
            break;
          case 'xlsx':
            contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            break;
        }

        print('📄 File: ${file.path}, Extension: .$extension, Content-Type: $contentType');

        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: http.MediaType.parse(contentType),
        );
        multipartFiles.add(multipartFile);
      }
    }

    return multipartFiles;
  }
}

