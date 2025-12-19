import 'package:equatable/equatable.dart';
import '../../../core/constants/vendor_filter_type.dart';

abstract class VendorListEvent extends Equatable {
  const VendorListEvent();

  @override
  List<Object?> get props => [];
}

class VendorListLoadRequested extends VendorListEvent {
  final String token;
  final VendorFilterType filterType;

  const VendorListLoadRequested(
    this.token, [
    this.filterType = VendorFilterType.all,
  ]);

  @override
  List<Object?> get props => [token, filterType];
}

class VendorListRefreshRequested extends VendorListEvent {
  final String token;
  final VendorFilterType filterType;

  const VendorListRefreshRequested(
    this.token, [
    this.filterType = VendorFilterType.all,
  ]);

  @override
  List<Object?> get props => [token, filterType];
}
