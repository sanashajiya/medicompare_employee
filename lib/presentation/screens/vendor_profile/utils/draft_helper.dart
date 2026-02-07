import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../domain/entities/draft_vendor_entity.dart';
import '../../../../presentation/blocs/vendor_stepper/vendor_stepper_state.dart';
import '../models/additional_document_model.dart';

class DraftHelper {
  /// Helper function to safely copy file with proper handling
  /// Reads file into memory first to avoid file handle issues
  /// Returns the path of the saved file (either copied or original if already in draft dir)
  static Future<String?> _copySafeFile(
    File sourceFile,
    String destinationPath,
  ) async {
    try {
      // Check if source file exists and is not empty
      if (!await sourceFile.exists()) {
        print('⚠️ Source file does not exist: ${sourceFile.path}');
        return null;
      }

      final fileSize = await sourceFile.length();
      if (fileSize == 0) {
        print('⚠️ Source file is empty: ${sourceFile.path}');
        return null;
      }

      // Normalize paths for comparison (handle Windows/Unix path differences)
      final sourcePath = sourceFile.absolute.path.replaceAll('\\', '/');
      final destPath = File(
        destinationPath,
      ).absolute.path.replaceAll('\\', '/');

      if (sourcePath == destPath) {
        // File is already in the destination, no need to copy
        print(
          '✅ File already in draft directory: $destinationPath ($fileSize bytes)',
        );
        return destinationPath;
      }

      // Delete the destination file if it exists to prevent copy issues
      final destFile = File(destinationPath);
      if (await destFile.exists()) {
        try {
          await destFile.delete();
          print('✅ Deleted old destination file: $destinationPath');
        } catch (e) {
          print('⚠️ Could not delete existing destination file: $e');
        }
      }

      // Read the source file into memory to avoid file handle issues
      print(
        '📖 Reading source file into memory: ${sourceFile.path} ($fileSize bytes)',
      );
      final bytes = await sourceFile.readAsBytes();

      if (bytes.isEmpty) {
        print('❌ Source file read resulted in empty bytes: ${sourceFile.path}');
        return null;
      }

      // Write bytes to destination
      print(
        '✍️ Writing ${bytes.length} bytes to destination: $destinationPath',
      );
      await destFile.writeAsBytes(bytes);

      // Verify the write was successful
      final writtenSize = await destFile.length();
      if (writtenSize == 0) {
        print('❌ Destination file is empty after write: $destinationPath');
        // Try to delete the empty file
        try {
          await destFile.delete();
        } catch (e) {
          print('⚠️ Could not delete empty file: $e');
        }
        return null;
      }

      if (writtenSize != bytes.length) {
        print(
          '⚠️ Written size ($writtenSize) does not match source size (${bytes.length}): $destinationPath',
        );
      }

      print(
        '✅ File copied successfully: $destinationPath ($writtenSize bytes)',
      );
      return destFile.path;
    } catch (e) {
      print('❌ Error copying file: $e');
      return null;
    }
  }

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

      // Save Id Proof Image
      String? aadhaarFrontImagePath;
      if (formData['aadhaarFrontImage'] != null &&
          formData['aadhaarFrontImage'] is File) {
        final file = formData['aadhaarFrontImage'] as File;
        final extension = file.path.split('.').last;
        aadhaarFrontImagePath = await _copySafeFile(
          file,
          '${draftDir.path}/aadhaar_front.$extension',
        );
      }

      // Save Govt Id Proof Back Image
      String? aadhaarBackImagePath;
      if (formData['aadhaarBackImage'] != null &&
          formData['aadhaarBackImage'] is File) {
        final file = formData['aadhaarBackImage'] as File;
        final extension = file.path.split('.').last;
        aadhaarBackImagePath = await _copySafeFile(
          file,
          '${draftDir.path}/aadhaar_back.$extension',
        );
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
        panCardFilePath = await _copySafeFile(
          file,
          '${draftDir.path}/pan_card.$extension',
        );
      }

      if (formData['gstCertificateFile'] != null &&
          formData['gstCertificateFile'] is File) {
        final file = formData['gstCertificateFile'] as File;
        final extension = file.path.split('.').last;
        gstCertificateFilePath = await _copySafeFile(
          file,
          '${draftDir.path}/gst_certificate.$extension',
        );
      }

      if (formData['businessRegistrationFile'] != null &&
          formData['businessRegistrationFile'] is File) {
        final file = formData['businessRegistrationFile'] as File;
        final extension = file.path.split('.').last;
        businessRegistrationFilePath = await _copySafeFile(
          file,
          '${draftDir.path}/business_registration.$extension',
        );
      }

      if (formData['professionalLicenseFile'] != null &&
          formData['professionalLicenseFile'] is File) {
        final file = formData['professionalLicenseFile'] as File;
        final extension = file.path.split('.').last;
        professionalLicenseFilePath = await _copySafeFile(
          file,
          '${draftDir.path}/professional_license.$extension',
        );
      }

      if (formData['additionalDocumentFile'] != null &&
          formData['additionalDocumentFile'] is File) {
        final file = formData['additionalDocumentFile'] as File;
        final extension = file.path.split('.').last;
        additionalDocumentFilePath = await _copySafeFile(
          file,
          '${draftDir.path}/additional_document.$extension',
        );
      }

      // Save additional documents list
      List<Map<String, String>> additionalDocuments = [];
      if (formData['additionalDocuments'] != null &&
          formData['additionalDocuments'] is List) {
        final docs = formData['additionalDocuments'] as List;
        for (int i = 0; i < docs.length; i++) {
          // Check if it's our model
          if (docs[i] is AdditionalDocumentModel) {
            final doc = docs[i] as AdditionalDocumentModel;
            String? savedPath =
                doc.fileUrl; // Keep existing path if not new file

            if (doc.file != null) {
              final extension = doc.file!.path.split('.').last;
              savedPath = await _copySafeFile(
                doc.file!,
                '${draftDir.path}/additional_doc_${i}_${DateTime.now().millisecondsSinceEpoch}.$extension',
              );
            }

            additionalDocuments.add({
              'name': doc.nameController.text,
              'number': doc.numberController.text,
              'expiryDate': doc.expiryDateController.text,
              'filePath': savedPath ?? '',
            });
          }
        }
      }

      // Save front store images
      List<String> frontStoreImagePaths = [];
      if (formData['frontStoreImages'] != null &&
          formData['frontStoreImages'] is List<File>) {
        final images = formData['frontStoreImages'] as List<File>;
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final extension = file.path.split('.').last;
          final savedPath = await _copySafeFile(
            file,
            '${draftDir.path}/front_image_$i.$extension',
          );
          if (savedPath != null) {
            frontStoreImagePaths.add(savedPath);
          }
        }
      }

      // Save Store Logo
      String? storeLogoPath;
      if (formData['storeLogo'] != null && formData['storeLogo'] is File) {
        final file = formData['storeLogo'] as File;
        final extension = file.path.split('.').last;
        storeLogoPath = await _copySafeFile(
          file,
          '${draftDir.path}/store_logo.$extension',
        );
      }

      // Save Profile Banner
      String? profileBannerPath;
      if (formData['profileBanner'] != null &&
          formData['profileBanner'] is File) {
        final file = formData['profileBanner'] as File;
        final extension = file.path.split('.').last;
        profileBannerPath = await _copySafeFile(
          file,
          '${draftDir.path}/profile_banner.$extension',
        );
      }

      // Save signature
      String? signatureImagePath;
      if (formData['signatureBytes'] != null &&
          formData['signatureBytes'] is Uint8List) {
        final bytes = formData['signatureBytes'] as Uint8List;
        try {
          final signatureFile = File('${draftDir.path}/signature.png');
          // Delete old signature file if it exists
          if (await signatureFile.exists()) {
            try {
              await signatureFile.delete();
            } catch (e) {
              print('⚠️ Could not delete existing signature: $e');
            }
          }
          await signatureFile.writeAsBytes(bytes);
          // Verify signature was written
          final sigSize = await signatureFile.length();
          if (sigSize > 0) {
            signatureImagePath = signatureFile.path;
            print(
              '✅ Signature saved successfully: $signatureImagePath ($sigSize bytes)',
            );
          } else {
            print('❌ Signature file is empty after write');
          }
        } catch (e) {
          print('❌ Error saving signature: $e');
        }
      }

      final draft = DraftVendorEntity(
        id: draftId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentSectionIndex: stepperState.currentSection,
        firstName: formData['firstName'] ?? '',
        lastName: formData['lastName'] ?? '',
        email: formData['email'] ?? '',
        mobile: formData['mobile'] ?? '',
        aadhaarNumber: formData['aadhaarNumber'] ?? '',
        idProofType: formData['idProofType'],
        residentialAddress: formData['residentialAddress'] ?? '',
        aadhaarFrontImagePath: aadhaarFrontImagePath,
        aadhaarBackImagePath: aadhaarBackImagePath,
        businessName: formData['businessName'] ?? '',
        businessLegalName: formData['businessLegalName'] ?? '',
        businessEmail: formData['businessEmail'] ?? '',
        businessMobile: formData['businessMobile'] ?? '',
        altBusinessMobile: formData['altBusinessMobile'] ?? '',
        businessAddress: formData['businessAddress'] ?? '',
        latitude: formData['latitude'],
        longitude: formData['longitude'],
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
        panCardExpiryDate: formData['panCardExpiryDate'] ?? '',
        gstCertificateNumber: formData['gstCertificateNumber'] ?? '',
        gstCertificateFilePath: gstCertificateFilePath,
        gstExpiryDate: formData['gstExpiryDate'] ?? '',
        businessRegistrationNumber:
            formData['businessRegistrationNumber'] ?? '',
        businessRegistrationFilePath: businessRegistrationFilePath,
        businessRegistrationExpiryDate:
            formData['businessRegistrationExpiryDate'] ?? '',
        professionalLicenseNumber: formData['professionalLicenseNumber'] ?? '',
        professionalLicenseFilePath: professionalLicenseFilePath,
        professionalLicenseExpiryDate:
            formData['professionalLicenseExpiryDate'] ?? '',
        additionalDocumentName: formData['additionalDocumentName'] ?? '',
        additionalDocumentFilePath: additionalDocumentFilePath,
        additionalDocumentExpiryDate:
            formData['additionalDocumentExpiryDate'] ?? '',
        additionalDocuments: additionalDocuments,
        frontStoreImagePaths: frontStoreImagePaths,
        storeLogoPath: storeLogoPath,
        profileBannerPath: profileBannerPath,
        signatureImagePath: signatureImagePath,
        signerName: formData['signerName'] ?? '',
        acceptedTerms: formData['acceptedTerms'] ?? false,
        consentAccepted: formData['consentAccepted'] ?? false,
        pricingAgreementAccepted: formData['pricingAgreementAccepted'] ?? false,
        slvAgreementAccepted: formData['slvAgreementAccepted'] ?? false,
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
    String? idProofType,
    double? latitude,
    double? longitude,
    File? aadhaarFrontImage,
    File? aadhaarBackImage,
    File? panCardFile,
    File? gstCertificateFile,
    File? businessRegistrationFile,
    File? professionalLicenseFile,
    File? additionalDocumentFile,
    List<AdditionalDocumentModel>? additionalDocuments,
    List<File>? frontStoreImages,
    File? storeLogo,
    File? profileBanner,
    Uint8List? signatureBytes,
    List<String>? categories,
    String? signerName,
    bool? acceptedTerms,
    bool? consentAccepted,
    bool? pricingAgreementAccepted,
    bool? slvAgreementAccepted,
  }) {
    return {
      'firstName': controllers['firstName']?.text ?? '',
      'lastName': controllers['lastName']?.text ?? '',
      'email': controllers['email']?.text ?? '',
      'mobile': controllers['mobile']?.text ?? '',
      'aadhaarNumber': controllers['aadhaarNumber']?.text ?? '',
      'idProofType': idProofType,
      'residentialAddress': controllers['residentialAddress']?.text ?? '',
      'aadhaarFrontImage': aadhaarFrontImage,
      'aadhaarBackImage': aadhaarBackImage,
      'businessName': controllers['businessName']?.text ?? '',
      'businessLegalName': controllers['businessLegalName']?.text ?? '',
      'businessEmail': controllers['businessEmail']?.text ?? '',
      'businessMobile': controllers['businessMobile']?.text ?? '',
      'altBusinessMobile': controllers['altBusinessMobile']?.text ?? '',
      'businessAddress': controllers['businessAddress']?.text ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories ?? [],
      'accountNumber': controllers['accountNumber']?.text ?? '',
      'accountHolderName': controllers['accountHolderName']?.text ?? '',
      'ifscCode': controllers['ifscCode']?.text ?? '',
      'bankName': controllers['bankName']?.text ?? '',
      'bankBranch': controllers['bankBranch']?.text ?? '',
      'panCardNumber': controllers['panCardNumber']?.text ?? '',
      'panCardFile': panCardFile,
      'panCardExpiryDate': controllers['panCardExpiryDate']?.text ?? '',
      'gstCertificateNumber': controllers['gstCertificateNumber']?.text ?? '',
      'gstCertificateFile': gstCertificateFile,
      'gstExpiryDate': controllers['gstExpiryDate']?.text ?? '',
      'businessRegistrationNumber':
          controllers['businessRegistrationNumber']?.text ?? '',
      'businessRegistrationFile': businessRegistrationFile,
      'businessRegistrationExpiryDate':
          controllers['businessRegistrationExpiryDate']?.text ?? '',
      'professionalLicenseNumber':
          controllers['professionalLicenseNumber']?.text ?? '',
      'professionalLicenseFile': professionalLicenseFile,
      'professionalLicenseExpiryDate':
          controllers['professionalLicenseExpiryDate']?.text ?? '',
      'additionalDocumentName':
          controllers['additionalDocumentName']?.text ?? '',
      'additionalDocumentFile': additionalDocumentFile,
      'additionalDocumentExpiryDate':
          controllers['additionalDocumentExpiryDate']?.text ?? '',
      'additionalDocuments': additionalDocuments ?? [],
      'frontStoreImages': frontStoreImages ?? [],
      'storeLogo': storeLogo,
      'profileBanner': profileBanner,
      'signatureBytes': signatureBytes,
      'signerName': signerName ?? '',
      'acceptedTerms': acceptedTerms ?? false,
      'consentAccepted': consentAccepted ?? false,
      'pricingAgreementAccepted': pricingAgreementAccepted ?? false,
      'slvAgreementAccepted': slvAgreementAccepted ?? false,
    };
  }
}
