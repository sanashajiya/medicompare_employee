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
    required super.expiryDates,
    required super.files,
    required super.frontimages,
    required super.backimages,
    required super.signature,
    super.storeLogo,
    super.profileBanner,
    required super.bankName,
    required super.accountName,
    required super.accountNumber,
    required super.ifscCode,
    required super.branchName,
    super.otp,
    super.proofType,
    super.latitude,
    super.longitude,
    super.vendorId,
    super.consentAccepted,
    super.pricingAgreementAccepted,
    super.slvAgreementAccepted,
    super.success,
    super.message,
  });

  // 🔹 Backend → Entity (from vendor details endpoint)
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
      businessName: json['businessName'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      altMobile: json['alt_mobile'] ?? '',
      address: json['residentaladdress'] ?? '',
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
      expiryDates: json['expiryDate'] != null
          ? List<String>.from(json['expiryDate'])
          : [],
      files: const [],
      frontimages: const [],
      backimages: const [],
      signature: const [],
      bankName: json['bankName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branchName: json['branchName'] ?? '',
      vendorId: json['vendorId'] ?? json['_id'],
      consentAccepted: json['consentAccepted'] ?? false,
      pricingAgreementAccepted: json['pricingAgreementAccepted'] ?? false,
      slvAgreementAccepted: json['slvAgreementAccepted'] ?? false,
      success: json['success'],
      message: json['message'],
    );
  }

  // 🔹 Vendor List Response → Entity (from vendor list endpoint)
  factory VendorModel.fromVendorListJson(Map<String, dynamic> json) {
    // Extract bank data
    final bank = json['bank'] as Map<String, dynamic>?;
    final bankName = bank?['bank_name']?.toString() ?? '';
    final accountName = bank?['account_holder_name']?.toString() ?? '';
    final accountNumber = bank?['account_number']?.toString() ?? '';
    final ifscCode = bank?['ifsc_code']?.toString() ?? '';
    final branchName = bank?['branch']?.toString() ?? '';

    // Extract documents data
    final documents = json['documents'] as Map<String, dynamic>?;
    final documentsDetails =
        documents?['documentsDetails'] as List<dynamic>? ?? [];
    final signname = documents?['signname']?.toString() ?? '';

    // Extract document arrays
    final docNames = <String>[];
    final docIds = <String>[];
    final documentNumbers = <String>[];
    final expiryDates = <String>[];

    for (final doc in documentsDetails) {
      if (doc is Map<String, dynamic>) {
        docNames.add(doc['name']?.toString() ?? '');
        docIds.add(doc['doc_id']?.toString() ?? '');
        documentNumbers.add(doc['documentNumber']?.toString() ?? '');
        expiryDates.add(doc['expiryDate']?.toString() ?? '');
      }
    }

    // Extract categories
    final categoryIds = json['categoryIds'] as List<dynamic>? ?? [];
    final categories = categoryIds.map((e) => e.toString()).toList();

    return VendorModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      adharnumber: json['adharnumber']?.toString() ?? '',
      residentaladdress: json['residentaladdress']?.toString() ?? '',
      signname: signname,
      businessName: json['businessName']?.toString() ?? '',
      businessEmail: json['businessEmail']?.toString() ?? '',
      altMobile: json['altMobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      categories: categories,
      bussinessmobile: json['bussinessmobile']?.toString() ?? '',
      bussinesslegalname: json['bussinesslegalname']?.toString() ?? '',
      docNames: docNames,
      docIds: docIds,
      documentNumbers: documentNumbers,
      expiryDates: expiryDates,
      files: const [],
      frontimages: const [],
      backimages: const [],
      signature: const [],
      storeLogo: null,
      profileBanner: null,
      bankName: bankName,
      accountName: accountName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      branchName: branchName,
      vendorId: json['_id']?.toString() ?? json['vendorsId']?.toString(),
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
      proofType: entity.proofType,
      businessName: entity.businessName,
      businessEmail: entity.businessEmail,
      altMobile: entity.altMobile,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      categories: entity.categories,
      bussinessmobile: entity.bussinessmobile,
      bussinesslegalname: entity.bussinesslegalname,
      docNames: entity.docNames,
      docIds: entity.docIds,
      documentNumbers: entity.documentNumbers,
      expiryDates: entity.expiryDates,
      files: entity.files,
      frontimages: entity.frontimages,
      backimages: entity.backimages,
      signature: entity.signature,
      storeLogo: entity.storeLogo,
      profileBanner: entity.profileBanner,
      bankName: entity.bankName,
      accountName: entity.accountName,
      accountNumber: entity.accountNumber,
      ifscCode: entity.ifscCode,
      branchName: entity.branchName,
      otp: entity.otp,
      vendorId: entity.vendorId,
      consentAccepted: entity.consentAccepted,
      pricingAgreementAccepted: entity.pricingAgreementAccepted,
      slvAgreementAccepted: entity.slvAgreementAccepted,
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
      'consent_accepted': consentAccepted.toString(),
      'pricing_agreement_accepted': pricingAgreementAccepted.toString(),
      'slv_agreement_accepted': slvAgreementAccepted.toString(),
    };

    // New Fields Integration
    if (proofType != null && proofType!.isNotEmpty) {
      fields['proofType'] = proofType!;
    }

    if (latitude != null && longitude != null) {
      // Backend expects: location: { "lat": <double>, "lng": <double> }
      // This will be sent as a serialized JSON string in multipart field
      // but we need to import dart:convert.
      // Assuming outer scope has explicit import or we use string interpolation carefully?
      // Better to use string construction to avoid dependency if not already there,
      // but JSON is safer.
      // Let's use simple string construction or add import.
      // The file doesn't have dart:convert. I will add it in a separate step or just format manually if simple.
      // Manual format: '{"lat": $latitude, "lng": $longitude}'
      fields['location'] = '{"lat": $latitude, "lng": $longitude}';
    }

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

    final safeExpiryDates = <String>[];
    for (int i = 0; i < maxLength; i++) {
      if (i < expiryDates.length) {
        safeExpiryDates.add(expiryDates[i]);
      } else {
        safeExpiryDates.add('');
      }
    }

    return {
      'categories[]': categories,
      'doc_name[]': docNames,
      'doc_id[]': docIds,
      'documentNumber[]': safeDocumentNumbers,
      'expireDate[]': safeExpiryDates, // UPDATED KEY: expireDate[]
    };
  }

  /// 🔹 Multipart FILES (Photos + Signature + Documents)
  Future<List<http.MultipartFile>> toMultipartFiles() async {
    final filesList = <http.MultipartFile>[];

    print('\n═══════════════════════════════════════════════════════════════');
    print('📤 PREPARING MULTIPART FILES');
    print('═══════════════════════════════════════════════════════════════');
    print('🆔 Govt Id Proof Image: ${aadhaarFrontImage != null ? "✅" : "❌"}');
    print(
      '🆔 Govt Id Proof Back Image: ${aadhaarBackImage != null ? "✅" : "❌"}',
    );
    print('📸 Front Images: ${frontimages.length}');
    print('📷 Back Images: ${backimages.length}');
    print('✍️  signature: ${signature.length}');
    print('📄 Documents: ${files.length}');

    MediaType mediaType(String path) {
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

    // 🔹 Govt Id Proof Image - API expects 'adhaarfrontimage'
    if (aadhaarFrontImage != null) {
      final file = aadhaarFrontImage!;
      final exists = await file.exists();
      print('\n  🆔 Govt Id Proof Image:');
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
              contentType: mediaType(file.path),
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

    // 🔹 Govt Id Proof Back Image - API expects 'adhaarbackimage'
    if (aadhaarBackImage != null) {
      final file = aadhaarBackImage!;
      final exists = await file.exists();
      print('\n  🆔 Govt Id Proof Back Image:');
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
              contentType: mediaType(file.path),
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

    // 🔹 Front Images - API expects 'frontimage[]'
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
              'frontimage[]', // Updated to array notation
              file.path,
              contentType: mediaType(file.path),
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

    // 🔹 Back Images - API expects 'backimage[]'
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
              'backimage[]', // Updated to array notation
              file.path,
              contentType: mediaType(file.path),
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

    // 🔹 Signature - API expects 'signature[]'
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
              'signature[]', // Updated to array notation
              file.path,
              contentType: mediaType(file.path),
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

    // 🔹 Store Logo - API expects 'logo'
    if (storeLogo != null) {
      final file = storeLogo!;
      final exists = await file.exists();
      print('\n  🏪 Store Logo:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'logo', // UPDATED KEY: logo
              file.path,
              contentType: mediaType(file.path),
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

    // 🔹 Profile Banner - API expects 'banner'
    if (profileBanner != null) {
      final file = profileBanner!;
      final exists = await file.exists();
      print('\n  🖼️ Profile Banner:');
      print('     Path: ${file.path}');
      print('     Exists: $exists');
      if (exists) {
        try {
          final size = await file.length();
          print('     Size: $size bytes');
          filesList.add(
            await http.MultipartFile.fromPath(
              'banner', // UPDATED KEY: banner
              file.path,
              contentType: mediaType(file.path),
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

    // 🔹 Documents - API expects 'file'
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
                'file[]',
                file.path,
                contentType: mediaType(file.path),
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
