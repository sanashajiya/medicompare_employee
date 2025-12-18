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
    super.aadhaarFrontImage,
    super.aadhaarBackImage,
    super.signname,
    super.adharnumber,
    super.residentaladdress,
    required super.businessName,
    required super.businessEmail,
    required super.altMobile,
    required super.address,
    required super.categories,
    required super.bussinessmobile,
    super.bussinesslegalname,
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
    super.otp,
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
      aadhaarFrontImage: entity.aadhaarFrontImage,
      aadhaarBackImage: entity.aadhaarBackImage,
      signname: entity.signname,
      adharnumber: entity.adharnumber,
      residentaladdress: entity.residentaladdress,
      businessName: entity.businessName,
      businessEmail: entity.businessEmail,
      altMobile: entity.altMobile,
      address: entity.address,
      categories: entity.categories,
      bussinessmobile: entity.bussinessmobile,
      bussinesslegalname: entity.bussinesslegalname,
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
      otp: entity.otp,
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
      'signname': signname,
      'bussinesslegalname': bussinesslegalname,
      'adharnumber': adharnumber,
      'residentaladdress': residentaladdress,
    };

    // Add OTP if provided (ALWAYS add type and usertype when OTP is present)
    final otpValue = otp;
    print('🔍 DEBUG: Checking OTP in toMultipartFields()');
    print('   otp field value: $otpValue');
    print('   otp is null: ${otpValue == null}');
    print('   otp is empty: ${otpValue?.isEmpty ?? true}');

    if (otpValue != null && otpValue.isNotEmpty) {
      fields['otp'] = otpValue;
      // Add type and usertype when OTP is present (required for OTP verification)
      // These must match the values used in send-otp API
      fields['type'] = 'phone';
      fields['usertype'] = 'app';
      print('✅ Adding OTP fields: otp=$otpValue, type=phone, usertype=app');
    } else {
      print('❌ ERROR: OTP is null or empty! OTP verification will fail.');
      print(
        '   This means the OTP was not passed from VendorEntity to VendorModel',
      );
    }

    return fields;
  }

  /// 🔹 Array fields that need to be added multiple times with the same key
  Map<String, List<String>> toMultipartArrayFields() {
    // Ensure documentNumber array has the same length as docNames/docIds
    // and replace empty strings with a placeholder to prevent backend errors
    final safeDocumentNumbers = <String>[];
    final maxLength = [
      docNames.length,
      docIds.length,
      documentNumbers.length,
    ].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      if (i < documentNumbers.length) {
        // Use the actual value if it exists and is not empty, otherwise use empty string
        safeDocumentNumbers.add(documentNumbers[i]);
      } else {
        // Pad with empty string to match array lengths
        safeDocumentNumbers.add('');
      }
    }

    return {
      'categories[]': categories,
      'doc_name[]': docNames,
      'doc_id[]': docIds,
      'documentNumber[]': safeDocumentNumbers,
    };
  }

  /// 🔹 Multipart FILES (Photos + Signature + Documents)
  Future<List<http.MultipartFile>> toMultipartFiles() async {
    final filesList = <http.MultipartFile>[];

    print('\n═══════════════════════════════════════════════════════════════');
    print('📤 PREPARING MULTIPART FILES');
    print('═══════════════════════════════════════════════════════════════');
    print('🆔 Aadhaar Front Image: ${aadhaarFrontImage != null ? "✅" : "❌"}');
    print('🆔 Aadhaar Back Image: ${aadhaarBackImage != null ? "✅" : "❌"}');
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

    // 🔹 Aadhaar Front Image - API expects 'adhaarfrontimage'
    if (aadhaarFrontImage != null) {
      final file = aadhaarFrontImage!;
      final exists = await file.exists();
      print('\n  🆔 Aadhaar Front Image:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'adhaarfrontimage',
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

    // 🔹 Aadhaar Back Image - API expects 'adhaarbackimage'
    if (aadhaarBackImage != null) {
      final file = aadhaarBackImage!;
      final exists = await file.exists();
      print('\n  🆔 Aadhaar Back Image:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'adhaarbackimage',
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
