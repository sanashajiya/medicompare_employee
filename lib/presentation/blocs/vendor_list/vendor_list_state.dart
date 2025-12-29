import 'package:equatable/equatable.dart';
import '../../../domain/entities/vendor_list_item_entity.dart';

abstract class VendorListState extends Equatable {
  const VendorListState();

  @override
  List<Object?> get props => [];
}

class VendorListInitial extends VendorListState {}

class VendorListLoading extends VendorListState {}

class VendorListLoaded extends VendorListState {
  final List<VendorListItemEntity> vendors;

  const VendorListLoaded({required this.vendors});

  @override
  List<Object?> get props => [vendors];
}

class VendorListError extends VendorListState {
  final String message;

  const VendorListError({required this.message});

  @override
  List<Object?> get props => [message];
}
