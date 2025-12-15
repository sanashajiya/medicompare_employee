import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_vendor_usecase.dart';
import 'vendor_form_event.dart';
import 'vendor_form_state.dart';

class VendorFormBloc extends Bloc<VendorFormEvent, VendorFormState> {
  final CreateVendorUseCase createVendorUseCase;

  VendorFormBloc({
    required this.createVendorUseCase,
  }) : super(VendorFormInitial()) {
    on<VendorFormSubmitted>(_onVendorFormSubmitted);
    on<VendorFormReset>(_onVendorFormReset);
  }

  Future<void> _onVendorFormSubmitted(
    VendorFormSubmitted event,
    Emitter<VendorFormState> emit,
  ) async {
    emit(VendorFormSubmitting());

    try {
      final vendor = await createVendorUseCase(event.vendor, event.token);
      emit(VendorFormSuccess(vendor, vendor.message ?? 'Vendor created successfully'));
    } catch (e) {
      emit(VendorFormFailure(e.toString()));
    }
  }

  void _onVendorFormReset(
    VendorFormReset event,
    Emitter<VendorFormState> emit,
  ) {
    emit(VendorFormInitial());
  }
}

