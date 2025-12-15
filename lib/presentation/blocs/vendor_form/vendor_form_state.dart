import 'package:equatable/equatable.dart';
import '../../../domain/entities/vendor_entity.dart';

abstract class VendorFormState extends Equatable {
  const VendorFormState();

  @override
  List<Object?> get props => [];
}

class VendorFormInitial extends VendorFormState {}

class VendorFormSubmitting extends VendorFormState {}

class VendorFormSuccess extends VendorFormState {
  final VendorEntity vendor;
  final String message;

  const VendorFormSuccess(this.vendor, [this.message = 'Vendor created successfully']);

  @override
  List<Object?> get props => [vendor, message];
}

class VendorFormFailure extends VendorFormState {
  final String error;

  const VendorFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}

