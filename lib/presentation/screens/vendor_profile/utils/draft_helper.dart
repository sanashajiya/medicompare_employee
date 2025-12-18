import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../domain/entities/draft_vendor_entity.dart';
import '../../../../presentation/blocs/vendor_stepper/vendor_stepper_state.dart';

class DraftHelper {
  /// Convert form data to draft entity
  static Future<DraftVendorEntity?> createDraftFromFormData({
    required String draftId,
    required VendorStepperState stepperState,
    required Map<String, dynamic> formData,
  }) async {
    try {
      // Save files to temporary storage and get paths
      final tempDir = await getApplicationDocumentsDirectory();
      final draftDir = Directory('${tempDir.path}/drafts/$draftId');
      if (!await draftDir.exists()) {
        await draftDir.create(recursive: true);
      }

      // Save aadhaar photo
      String? aadhaarPhotoPath;
      if (formData['aadhaarPhoto'] != null &&
          formData['aadhaarPhoto'] is File) {
        final file = formData['aadhaarPhoto'] as File;
        final savedFile = await file.copy('${draftDir.path}/aadhaar_photo.jpg');
        aadhaarPhotoPath = savedFile.path;
      }

      // Save document files
      String? panCardFilePath;
      String? gstCertificateFilePath;
      String? businessRegistrationFilePath;
      String? professionalLicenseFilePath;
      String? additionalDocumentFilePath;

      if (formData['panCardFile'] != null && formData['panCardFile'] is File) {
        final file = formData['panCardFile'] as File;
        final extension = file.path.split('.').last;
        final savedFile = await file.copy(
          '${draftDir.path}/pan_card.$extension',
        );
        panCardFilePath = savedFile.path;
      }

      if (formData['gstCertificateFile'] != null &&
          formData['gstCertificateFile'] is File) {
        final file = formData['gstCertificateFile'] as File;
        final extension = file.path.split('.').last;
        final savedFile = await file.copy(
          '${draftDir.path}/gst_certificate.$extension',
        );
        gstCertificateFilePath = savedFile.path;
      }

      if (formData['businessRegistrationFile'] != null &&
          formData['businessRegistrationFile'] is File) {
        final file = formData['businessRegistrationFile'] as File;
        final extension = file.path.split('.').last;
        final savedFile = await file.copy(
          '${draftDir.path}/business_registration.$extension',
        );
        businessRegistrationFilePath = savedFile.path;
      }

      if (formData['professionalLicenseFile'] != null &&
          formData['professionalLicenseFile'] is File) {
        final file = formData['professionalLicenseFile'] as File;
        final extension = file.path.split('.').last;
        final savedFile = await file.copy(
          '${draftDir.path}/professional_license.$extension',
        );
        professionalLicenseFilePath = savedFile.path;
      }

      if (formData['additionalDocumentFile'] != null &&
          formData['additionalDocumentFile'] is File) {
        final file = formData['additionalDocumentFile'] as File;
        final extension = file.path.split('.').last;
        final savedFile = await file.copy(
          '${draftDir.path}/additional_document.$extension',
        );
        additionalDocumentFilePath = savedFile.path;
      }

      // Save front store images
      List<String> frontStoreImagePaths = [];
      if (formData['frontStoreImages'] != null &&
          formData['frontStoreImages'] is List<File>) {
        final images = formData['frontStoreImages'] as List<File>;
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final extension = file.path.split('.').last;
          final savedFile = await file.copy(
            '${draftDir.path}/front_image_$i.$extension',
          );
          frontStoreImagePaths.add(savedFile.path);
        }
      }

      // Save signature
      String? signatureImagePath;
      if (formData['signatureBytes'] != null &&
          formData['signatureBytes'] is Uint8List) {
        final bytes = formData['signatureBytes'] as Uint8List;
        final signatureFile = File('${draftDir.path}/signature.png');
        await signatureFile.writeAsBytes(bytes);
        signatureImagePath = signatureFile.path;
      }

      final draft = DraftVendorEntity(
        id: draftId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentSectionIndex: stepperState.currentSection,
        firstName: formData['firstName'] ?? '',
        lastName: formData['lastName'] ?? '',
        email: formData['email'] ?? '',
        password: formData['password'] ?? '',
        mobile: formData['mobile'] ?? '',
        aadhaarNumber: formData['aadhaarNumber'] ?? '',
        residentialAddress: formData['residentialAddress'] ?? '',
        aadhaarPhotoPath: aadhaarPhotoPath,
        businessName: formData['businessName'] ?? '',
        businessLegalName: formData['businessLegalName'] ?? '',
        businessEmail: formData['businessEmail'] ?? '',
        businessMobile: formData['businessMobile'] ?? '',
        altBusinessMobile: formData['altBusinessMobile'] ?? '',
        businessAddress: formData['businessAddress'] ?? '',
        categories: formData['categories'] is List
            ? List<String>.from(formData['categories'])
            : [],
        accountNumber: formData['accountNumber'] ?? '',
        accountHolderName: formData['accountHolderName'] ?? '',
        ifscCode: formData['ifscCode'] ?? '',
        bankName: formData['bankName'] ?? '',
        bankBranch: formData['bankBranch'] ?? '',
        panCardNumber: formData['panCardNumber'] ?? '',
        panCardFilePath: panCardFilePath,
        gstCertificateNumber: formData['gstCertificateNumber'] ?? '',
        gstCertificateFilePath: gstCertificateFilePath,
        businessRegistrationNumber:
            formData['businessRegistrationNumber'] ?? '',
        businessRegistrationFilePath: businessRegistrationFilePath,
        professionalLicenseNumber: formData['professionalLicenseNumber'] ?? '',
        professionalLicenseFilePath: professionalLicenseFilePath,
        additionalDocumentName: formData['additionalDocumentName'] ?? '',
        additionalDocumentFilePath: additionalDocumentFilePath,
        frontStoreImagePaths: frontStoreImagePaths,
        signatureImagePath: signatureImagePath,
        signerName: formData['signerName'] ?? '',
        acceptedTerms: formData['acceptedTerms'] ?? false,
        sectionCompleted: List<bool>.from(stepperState.sectionCompleted),
        sectionValidations: List<bool>.from(stepperState.sectionValidations),
      );

      // Only return draft if it has any data
      if (draft.hasAnyData) {
        return draft;
      }
      return null;
    } catch (e) {
      print('Error creating draft: $e');
      return null;
    }
  }

  /// Extract form data from vendor profile screen state
  static Map<String, dynamic> extractFormData({
    required Map<String, TextEditingController> controllers,
    File? aadhaarPhoto,
    File? panCardFile,
    File? gstCertificateFile,
    File? businessRegistrationFile,
    File? professionalLicenseFile,
    File? additionalDocumentFile,
    List<File>? frontStoreImages,
    Uint8List? signatureBytes,
    List<String>? categories,
    String? signerName,
    bool? acceptedTerms,
  }) {
    return {
      'firstName': controllers['firstName']?.text ?? '',
      'lastName': controllers['lastName']?.text ?? '',
      'email': controllers['email']?.text ?? '',
      'password': controllers['password']?.text ?? '',
      'mobile': controllers['mobile']?.text ?? '',
      'aadhaarNumber': controllers['aadhaarNumber']?.text ?? '',
      'residentialAddress': controllers['residentialAddress']?.text ?? '',
      'aadhaarPhoto': aadhaarPhoto,
      'businessName': controllers['businessName']?.text ?? '',
      'businessLegalName': controllers['businessLegalName']?.text ?? '',
      'businessEmail': controllers['businessEmail']?.text ?? '',
      'businessMobile': controllers['businessMobile']?.text ?? '',
      'altBusinessMobile': controllers['altBusinessMobile']?.text ?? '',
      'businessAddress': controllers['businessAddress']?.text ?? '',
      'categories': categories ?? [],
      'accountNumber': controllers['accountNumber']?.text ?? '',
      'accountHolderName': controllers['accountHolderName']?.text ?? '',
      'ifscCode': controllers['ifscCode']?.text ?? '',
      'bankName': controllers['bankName']?.text ?? '',
      'bankBranch': controllers['bankBranch']?.text ?? '',
      'panCardNumber': controllers['panCardNumber']?.text ?? '',
      'panCardFile': panCardFile,
      'gstCertificateNumber': controllers['gstCertificateNumber']?.text ?? '',
      'gstCertificateFile': gstCertificateFile,
      'businessRegistrationNumber':
          controllers['businessRegistrationNumber']?.text ?? '',
      'businessRegistrationFile': businessRegistrationFile,
      'professionalLicenseNumber':
          controllers['professionalLicenseNumber']?.text ?? '',
      'professionalLicenseFile': professionalLicenseFile,
      'additionalDocumentName':
          controllers['additionalDocumentName']?.text ?? '',
      'additionalDocumentFile': additionalDocumentFile,
      'frontStoreImages': frontStoreImages ?? [],
      'signatureBytes': signatureBytes,
      'signerName': signerName ?? '',
      'acceptedTerms': acceptedTerms ?? false,
    };
  }
}


