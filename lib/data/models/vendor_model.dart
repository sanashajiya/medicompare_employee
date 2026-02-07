import 'dart:convert';

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
    super.aadhaarFrontImageUrl,
    super.aadhaarBackImageUrl,
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
    super.docUrls,
    required super.frontimages,
    super.frontImageUrls,
    required super.backimages,
    super.backImageUrls,
    required super.signature,
    super.signatureImageUrl,
    super.storeLogo,
    super.storeLogoUrl,
    super.profileBanner,
    super.profileBannerUrl,
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

  // Helper to ensure full URL with prefix
  static String? _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    // Use the correct base URL
    const apiBaseUrl = 'https://api.medicompares.com/';
    // Prevent double slashes if path starts with /
    if (path.startsWith('/')) {
      return '$apiBaseUrl${path.substring(1)}';
    }
    return '$apiBaseUrl$path';
  }

  // 🔹 Backend → Entity (from vendor details endpoint)
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    // Helper parsers for this specific JSON structure
    String? getFirstPath(dynamic key) {
      if (json[key] is List && (json[key] as List).isNotEmpty) {
        return _getFullUrl(json[key][0]['path']?.toString());
      }
      return null;
    }

    // Parse documents if available
    List<String> parsedDocUrls = [];
    if (json['doc_path'] != null) {
      // Some endpoints return doc_path array directly
      parsedDocUrls = List<String>.from(
        json['doc_path'],
      ).map((e) => _getFullUrl(e) ?? '').toList();
    }

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
      proofType:
          json['proofType']?.toString() ?? json['idProofType']?.toString(),
      // Parse location if it exists
      latitude: json['location'] is Map
          ? (json['location']['lat'] is num
                ? (json['location']['lat'] as num).toDouble()
                : double.tryParse(json['location']['lat']?.toString() ?? ''))
          : null,
      longitude: json['location'] is Map
          ? (json['location']['lng'] is num
                ? (json['location']['lng'] as num).toDouble()
                : double.tryParse(json['location']['lng']?.toString() ?? ''))
          : null,
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
      docUrls: parsedDocUrls,
      frontimages: const [],
      frontImageUrls: const [],
      backimages: const [],
      backImageUrls: const [],
      signature: const [],
      signatureImageUrl: null,
      storeLogo: null,
      storeLogoUrl:
          (json['business'] != null &&
              json['business']['bussiness_image'] is Map)
          ? _getFullUrl(json['business']['bussiness_image']['url']?.toString())
          : (json['bussiness_image'] is Map
                ? _getFullUrl(json['bussiness_image']['url']?.toString())
                : null),
      profileBanner: null,
      profileBannerUrl:
          (json['business'] != null &&
              json['business']['bussiness_banner_image'] is Map)
          ? _getFullUrl(
              json['business']['bussiness_banner_image']['url']?.toString(),
            )
          : (json['bussiness_banner_image'] is Map
                ? _getFullUrl(json['bussiness_banner_image']['url']?.toString())
                : null),
      bankName: json['bankName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branchName: json['branchName'] ?? '',
      vendorId: json['vendorId'] ?? json['_id'],
      consentAccepted: json['consent'] ?? json['consentAccepted'] ?? false,
      pricingAgreementAccepted:
          json['pricingAgreement'] ?? json['pricingAgreementAccepted'] ?? false,
      slvAgreementAccepted:
          json['slvagreement'] ?? json['slvAgreementAccepted'] ?? false,
      success: json['success'],
      message: json['message'],
      aadhaarFrontImageUrl: getFirstPath('adhaarfrontimage'),
      aadhaarBackImageUrl: getFirstPath('adhaarbackimage'),
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

    // Extract business data
    final business = json['business'] as Map<String, dynamic>?;
    final businessName = business?['name']?.toString() ?? '';
    final businessEmail = business?['email']?.toString() ?? '';
    final businessLegalName = business?['bussinesslegalname']?.toString() ?? '';
    final businessMobile = business?['mobile']?.toString() ?? '';
    final altMobile = business?['alt_mobile']?.toString() ?? '';
    final businessAddress = business?['address']?.toString() ?? '';

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
    final docUrls = <String>[];

    for (final doc in documentsDetails) {
      if (doc is Map<String, dynamic>) {
        docNames.add(doc['name']?.toString() ?? '');
        docIds.add(doc['doc_id']?.toString() ?? '');
        documentNumbers.add(doc['documentNumber']?.toString() ?? '');
        expiryDates.add(
          doc['expireDate']?.toString() ?? doc['expiryDate']?.toString() ?? '',
        );
        docUrls.add(_getFullUrl(doc['path']?.toString()) ?? '');
      }
    }

    // Front Images
    final frontImagesRaw = documents?['frontImage'] as List<dynamic>?;
    final frontImageUrls =
        frontImagesRaw
            ?.map((e) {
              if (e is Map) return _getFullUrl(e['path']?.toString()) ?? '';
              return '';
            })
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    // Signature
    final signatureRaw = documents?['signature'] as List<dynamic>?;
    String? signatureUrl;
    if (signatureRaw != null &&
        signatureRaw.isNotEmpty &&
        signatureRaw[0] is Map) {
      signatureUrl = _getFullUrl(signatureRaw[0]['path']?.toString());
    }

    // Aadhaar Images
    final aadhaarFrontRaw = json['adhaarfrontimage'] as List<dynamic>?;
    String? aadhaarFrontUrl;
    if (aadhaarFrontRaw != null &&
        aadhaarFrontRaw.isNotEmpty &&
        aadhaarFrontRaw[0] is Map) {
      aadhaarFrontUrl = _getFullUrl(aadhaarFrontRaw[0]['path']?.toString());
    }

    final aadhaarBackRaw = json['adhaarbackimage'] as List<dynamic>?;
    String? aadhaarBackUrl;
    if (aadhaarBackRaw != null &&
        aadhaarBackRaw.isNotEmpty &&
        aadhaarBackRaw[0] is Map) {
      aadhaarBackUrl = _getFullUrl(aadhaarBackRaw[0]['path']?.toString());
    }

    // Extract categories
    // Check both root and business object for categoryIds
    var categoryIds = json['categoryIds'] as List<dynamic>?;
    if (categoryIds == null || categoryIds.isEmpty) {
      categoryIds = business?['categoryIds'] as List<dynamic>?;
    }
    final categories = categoryIds?.map((e) => e.toString()).toList() ?? [];

    // Location parsing
    final location = json['location'] as Map<String, dynamic>?;
    double? lat, lng;
    if (location != null &&
        location['coordinates'] is List &&
        (location['coordinates'] as List).isNotEmpty) {
      // Assuming GeoJSON [lng, lat]
      // If format is diff, adjust. Code below assumes { lat: ..., lng: ... } from previous code,
      // but user request says "coordinates": []. If empty, no location.
      // Let's stick to existing parsing logic if it works, or fallback to null.
      // Existing code tried to parse 'lat' and 'lng' keys.
    }

    return VendorModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      adharnumber:
          json['adharnumber']?.toString() ??
          json['aadhaarNumber']?.toString() ??
          json['aadharNumber']?.toString() ??
          '',
      residentaladdress: json['residentaladdress']?.toString() ?? '',
      signname: signname,
      businessName: businessName, // Use extracted business name
      businessEmail: businessEmail, // Use extracted
      altMobile: altMobile, // Use extracted
      address: businessAddress, // Use extracted business address
      proofType:
          json['proofType']?.toString() ?? json['idProofType']?.toString(),
      // Parse location if it exists
      latitude: json['location'] is Map
          ? (json['location']['lat'] is num
                ? (json['location']['lat'] as num).toDouble()
                : double.tryParse(json['location']['lat']?.toString() ?? ''))
          : null,
      longitude: json['location'] is Map
          ? (json['location']['lng'] is num
                ? (json['location']['lng'] as num).toDouble()
                : double.tryParse(json['location']['lng']?.toString() ?? ''))
          : null,
      categories: categories,
      bussinessmobile: businessMobile, // Use extracted
      bussinesslegalname: businessLegalName, // Use extracted
      docNames: docNames,
      docIds: docIds,
      documentNumbers: documentNumbers,
      expiryDates: expiryDates,
      files: const [],
      docUrls: docUrls,
      frontimages: const [],
      frontImageUrls: frontImageUrls,
      backimages: const [],
      backImageUrls: const [],
      signature: const [],
      signatureImageUrl: signatureUrl,
      storeLogo: null,
      storeLogoUrl:
          (json['business'] != null &&
              json['business']['bussiness_image'] is Map)
          ? _getFullUrl(json['business']['bussiness_image']['url']?.toString())
          : (json['bussiness_image'] is Map
                ? _getFullUrl(json['bussiness_image']['url']?.toString())
                : null),
      profileBanner: null,
      profileBannerUrl:
          (json['business'] != null &&
              json['business']['bussiness_banner_image'] is Map)
          ? _getFullUrl(
              json['business']['bussiness_banner_image']['url']?.toString(),
            )
          : (json['bussiness_banner_image'] is Map
                ? _getFullUrl(json['bussiness_banner_image']['url']?.toString())
                : null),
      bankName: bankName,
      accountName: accountName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      branchName: branchName,
      vendorId: json['_id']?.toString() ?? json['vendorsId']?.toString(),
      aadhaarFrontImageUrl: aadhaarFrontUrl,
      aadhaarBackImageUrl: aadhaarBackUrl,
      // Status fields
      success: true,
      message: 'Parsed from list',
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
      aadhaarFrontImageUrl: entity.aadhaarFrontImageUrl,
      aadhaarBackImageUrl: entity.aadhaarBackImageUrl,
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
      docUrls: entity.docUrls,
      frontimages: entity.frontimages,
      frontImageUrls: entity.frontImageUrls,
      backimages: entity.backimages,
      backImageUrls: entity.backImageUrls,
      signature: entity.signature,
      signatureImageUrl: entity.signatureImageUrl,
      storeLogo: entity.storeLogo,
      storeLogoUrl: entity.storeLogoUrl,
      profileBanner: entity.profileBanner,
      profileBannerUrl: entity.profileBannerUrl,
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

  /// 🔹 Convert to JSON map for JSON-based APIs
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
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
      'consent': consentAccepted,
      'pricingAgreement': pricingAgreementAccepted,
      'slvagreement': slvAgreementAccepted,
      'categories': categories,
      'proofType': proofType,
    };

    // Location
    if (latitude != null && longitude != null) {
      data['location'] = {'lat': latitude, 'lng': longitude};
    }

    // Vendor ID
    if (vendorId != null) {
      data['vendorId'] = vendorId;
    }

    // Document arrays
    // Note: In JSON, we can send arrays directly.
    // However, backend might expect separate arrays or objects.
    // Matching the multipart array structure but as normal JSON arrays
    data['doc_name'] = docNames;
    data['doc_id'] = docIds;
    data['documentNumber'] = documentNumbers;

    // Sanitize dates for JSON payload
    final safeExpiryDates = <String>[];
    for (var date in expiryDates) {
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) {
        try {
          final parts = date.split('/');
          date = '${parts[2]}-${parts[1]}-${parts[0]}';
        } catch (e) {
          // ignore error
        }
      }
      safeExpiryDates.add(date);
    }
    data['expireDate'] = safeExpiryDates;

    return data;
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
      'residentaladdress': residentaladdress,
      'consent': consentAccepted.toString(),
      'pricingAgreement': pricingAgreementAccepted.toString(),
      'slvagreement': slvAgreementAccepted.toString(),
    };

    // Only add adharnumber if it's not empty
    if (adharnumber.isNotEmpty) {
      fields['adharnumber'] = adharnumber;
    }

    // New Fields Integration
    if (proofType != null && proofType!.isNotEmpty) {
      fields['proofType'] = proofType!;
    }

    // Add debug print for business fields
    print(
      '🔍 DEBUG: Business Fields: Name=$businessName, Email=$businessEmail',
    );

    // Construct and add the 'business' JSON object field
    final Map<String, dynamic> businessMap = {
      'name': businessName,
      'email': businessEmail,
      'mobile': bussinessmobile.isNotEmpty ? bussinessmobile : mobile,
      'alt_mobile': altMobile,
      'address': address,
      'bussinesslegalname': bussinesslegalname,
    };

    if (latitude != null && longitude != null) {
      businessMap['location'] = {'lat': latitude, 'lng': longitude};
      // Also send flattened location for completeness
      fields['location'] = jsonEncode({'lat': latitude, 'lng': longitude});
      fields['businessLocation'] = jsonEncode({
        'lat': latitude,
        'lng': longitude,
      });
    }

    // Encode business object to JSON string
    fields['business'] = jsonEncode(businessMap);
    print('✅ Added business JSON field: ${fields['business']}');

    // Add vendorId if present (Required for Update API)
    if (vendorId != null && vendorId!.isNotEmpty) {
      fields['vendorId'] = vendorId!;
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

  /// 🔹 Flatten array fields into indexed keys for standard Multipart fields
  Map<String, String> toMultipartFlattenedArrayFields() {
    final flattened = <String, String>{};

    // Helper to add list
    void addList(String key, List<String> list) {
      for (int i = 0; i < list.length; i++) {
        flattened['$key[$i]'] = list[i];
      }
    }

    addList('categories', categories);
    // Filter out invalid docs (must have name, id, number, AND date)
    final validIndices = <int>[];
    for (int i = 0; i < docNames.length; i++) {
      final hasName = docNames[i].trim().isNotEmpty;
      final hasId = i < docIds.length && docIds[i].trim().isNotEmpty;
      final hasNumber =
          i < documentNumbers.length && documentNumbers[i].trim().isNotEmpty;
      final hasDate =
          i < expiryDates.length && expiryDates[i].trim().isNotEmpty;

      // Only include if ALL required fields are present
      if (hasName && hasId && hasNumber && hasDate) {
        validIndices.add(i);
      }
    }

    final filteredDocNames = validIndices.map((i) => docNames[i]).toList();
    final filteredDocIds = validIndices
        .map((i) => i < docIds.length ? docIds[i] : '')
        .toList();

    // safeDocumentNumbers logic with filtering
    final filteredDocumentNumbers = <String>[];
    for (int i in validIndices) {
      if (i < documentNumbers.length) {
        filteredDocumentNumbers.add(documentNumbers[i]);
      } else {
        filteredDocumentNumbers.add('');
      }
    }

    // safeExpiryDates logic with filtering and sanitization
    final filteredExpiryDates = <String>[];
    for (int i in validIndices) {
      String date = '';
      if (i < expiryDates.length) {
        date = expiryDates[i];
        // Sanitization logic remains same
        if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) {
          try {
            final parts = date.split('/');
            date = '${parts[2]}-${parts[1]}-${parts[0]}';
          } catch (e) {
            print('⚠️ Date sanitization failed for $date: $e');
          }
        } else if (date.contains('T')) {
          try {
            date = date.split('T')[0];
          } catch (e) {
            print('⚠️ ISO Date sanitization failed for $date: $e');
          }
        }
      }
      filteredExpiryDates.add(date);
    }

    addList('categories', categories); // Categories usually separate from docs
    addList('doc_name', filteredDocNames);
    addList('doc_id', filteredDocIds);
    addList('documentNumber', filteredDocumentNumbers);
    addList('expireDate', filteredExpiryDates);

    print('🔍 DEBUG: Generated Flattened Array Fields (Filtered):');
    flattened.forEach((key, value) {
      if (key.startsWith('expireDate') || key.startsWith('doc_name')) {
        print('   $key: $value');
      }
    });

    return flattened;
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

    // 🔹 Front Images - API expects 'frontimage' (multiple keys allowed)
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

    // 🔹 Back Images - API expects 'backimage'
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

    // 🔹 Signature - API expects 'signature'
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
              'logo',
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
              'banner',
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
                'file',
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
