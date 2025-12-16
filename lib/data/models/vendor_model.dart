import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    required super.frontimages,
    required super.backimages,
    required super.signature,
    required super.bankName,
    required super.accountName,
    required super.accountNumber,
    required super.ifscCode,
    required super.branchName,
    super.vendorId,
    super.success,
    super.message,
  });

  // 🔹 Backend → Entity
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
      docIds: json['doc_id'] != null ? List<String>.from(json['doc_id']) : [],
      documentNumbers: json['documentNumber'] != null
          ? List<String>.from(json['documentNumber'])
          : [],
      files: const [],
      frontimages: const [],
      backimages: const [],
      signature: const [],
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

  // 🔹 Entity → Model
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
      frontimages: entity.frontimages,
      backimages: entity.backimages,
      signature: entity.signature,
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

  /// 🔹 Multipart TEXT fields - returns regular fields and array fields separately
  Map<String, String> toMultipartFields() {
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

    return fields;
  }

  /// 🔹 Array fields that need to be added multiple times with the same key
  Map<String, List<String>> toMultipartArrayFields() {
    return {
      'categories[]': categories,
      'doc_name[]': docNames,
      'doc_id[]': docIds,
      'documentNumber[]': documentNumbers,
    };
  }

  /// 🔹 Multipart FILES (Photos + Signature + Documents)
  Future<List<http.MultipartFile>> toMultipartFiles() async {
    final filesList = <http.MultipartFile>[];

    print('\n═══════════════════════════════════════════════════════════════');
    print('📤 PREPARING MULTIPART FILES');
    print('═══════════════════════════════════════════════════════════════');
    print('📸 Front Images: ${frontimages.length}');
    print('📷 Back Images: ${backimages.length}');
    print('✍️  signature: ${signature.length}');
    print('📄 Documents: ${files.length}');

    MediaType _mediaType(String path) {
      final ext = path.split('.').last.toLowerCase();
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          return MediaType('image', 'jpeg');
        case 'png':
          return MediaType('image', 'png');
        case 'pdf':
          return MediaType('application', 'pdf');
        default:
          return MediaType('application', 'octet-stream');
      }
    }

    // 🔹 Front Images - API expects 'frontimage' (no brackets, singular)
    for (var i = 0; i < frontimages.length; i++) {
      final file = frontimages[i];
      final exists = await file.exists();
      print('\n  📸 Front Image [$i]:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'frontimage',
              file.path,
              contentType: _mediaType(file.path),
            ),
          );
          print('     ✅ Added to multipart');
        } catch (e) {
          print('     ❌ Error adding: $e');
        }
      } else {
        print('     ❌ FILE NOT FOUND!');
      }
    }

    // 🔹 Back Images - API expects 'backimage' (no brackets, singular)
    for (var i = 0; i < backimages.length; i++) {
      final file = backimages[i];
      final exists = await file.exists();
      print('\n  📷 Back Image [$i]:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'backimage',
              file.path,
              contentType: _mediaType(file.path),
            ),
          );
          print('     ✅ Added to multipart');
        } catch (e) {
          print('     ❌ Error adding: $e');
        }
      } else {
        print('     ❌ FILE NOT FOUND!');
      }
    }

    // 🔹 Signature - API expects 'signature' (no brackets)
    for (var i = 0; i < signature.length; i++) {
      final file = signature[i];
      final exists = await file.exists();
      print('\n  ✍️  Signature [$i]:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'signature',
              file.path,
              contentType: _mediaType(file.path),
            ),
          );
          print('     ✅ Added to multipart');
        } catch (e) {
          print('     ❌ Error adding: $e');
        }
      } else {
        print('     ❌ FILE NOT FOUND!');
      }
    }

    // 🔹 Documents - API expects 'file' (no brackets, singular)
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      if (file != null) {
        final exists = await file.exists();
        print('\n  📄 Document [$i]:');
        print('     Path: ${file.path}');
        print('     Exists: $exists');
        if (exists) {
          try {
            final size = await file.length();
            print('     Size: $size bytes');
            filesList.add(
              await http.MultipartFile.fromPath(
                'file',
                file.path,
                contentType: _mediaType(file.path),
              ),
            );
            print('     ✅ Added to multipart');
          } catch (e) {
            print('     ❌ Error adding: $e');
          }
        } else {
          print('     ❌ FILE NOT FOUND!');
        }
      }
    }

    print('\n═══════════════════════════════════════════════════════════════');
    print('📊 FINAL RESULT: ${filesList.length} files ready to send');
    print('═══════════════════════════════════════════════════════════════\n');

    return filesList;
  }
}

