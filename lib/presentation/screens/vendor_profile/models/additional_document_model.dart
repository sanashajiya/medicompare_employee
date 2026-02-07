import 'dart:io';

import 'package:flutter/material.dart';

class AdditionalDocumentModel {
  final String id;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController expiryDateController;
  File? file;
  String? fileUrl; // For edit mode / prefilled drafts
  String? fileName;

  AdditionalDocumentModel({
    String? id,
    String name = '',
    String number = '',
    String expiryDate = '',
    this.file,
    this.fileUrl,
    this.fileName,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       nameController = TextEditingController(text: name),
       numberController = TextEditingController(text: number),
       expiryDateController = TextEditingController(text: expiryDate);

  void dispose() {
    nameController.dispose();
    numberController.dispose();
    expiryDateController.dispose();
  }
}
