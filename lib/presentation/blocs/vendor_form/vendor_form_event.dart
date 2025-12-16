import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/vendor_entity.dart';

abstract class VendorFormEvent extends Equatable {
  const VendorFormEvent();

  @override
  List<Object?> get props => [];
}

class VendorFormSubmitted extends VendorFormEvent {
  final VendorEntity vendor;
  final String token;
  final List<File> frontimages; // Frontend photos
  final List<File> backimages; // Backend photos
  final List<File> signature; // Digital signature

  const VendorFormSubmitted(
    this.vendor,
    this.token, {
    this.frontimages = const [],
    this.backimages = const [],
    this.signature = const [],
  });

  @override
  List<Object?> get props => [
    vendor,
    token,
    frontimages,
    backimages,
    signature,
  ];
}

class VendorFormReset extends VendorFormEvent {}
