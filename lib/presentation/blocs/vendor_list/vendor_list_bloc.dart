import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_vendor_list_usecase.dart';
import 'vendor_list_event.dart';
import 'vendor_list_state.dart';

class VendorListBloc extends Bloc<VendorListEvent, VendorListState> {
  final GetVendorListUseCase getVendorListUseCase;

  VendorListBloc({required this.getVendorListUseCase})
    : super(VendorListInitial()) {
    on<VendorListLoadRequested>(_onLoadRequested);
    on<VendorListRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    VendorListLoadRequested event,
    Emitter<VendorListState> emit,
  ) async {
    emit(VendorListLoading());
    try {
      final vendors = await getVendorListUseCase(event.token);
      emit(VendorListLoaded(vendors: vendors));
    } catch (e) {
      emit(
        VendorListError(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onRefreshRequested(
    VendorListRefreshRequested event,
    Emitter<VendorListState> emit,
  ) async {
    emit(VendorListLoading());
    try {
      final vendors = await getVendorListUseCase(event.token);
      emit(VendorListLoaded(vendors: vendors));
    } catch (e) {
      emit(
        VendorListError(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }
}
