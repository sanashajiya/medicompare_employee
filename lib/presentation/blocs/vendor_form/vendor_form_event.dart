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

  const VendorFormSubmitted(this.vendor, this.token);

  @override
  List<Object?> get props => [vendor, token];
}

class VendorFormReset extends VendorFormEvent {}

