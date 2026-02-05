import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_vendor_usecase.dart';
import 'vendor_form_event.dart';
import 'vendor_form_state.dart';

class VendorFormBloc extends Bloc<VendorFormEvent, VendorFormState> {
  final CreateVendorUseCase createVendorUseCase;

  VendorFormBloc({required this.createVendorUseCase})
    : super(VendorFormInitial()) {
    on<VendorFormSubmitted>(_onVendorFormSubmitted);
    on<VendorFormReset>(_onVendorFormReset);
  }

  Future<void> _onVendorFormSubmitted(
    VendorFormSubmitted event,
    Emitter<VendorFormState> emit,
  ) async {
    emit(VendorFormSubmitting());

    try {
      // ✅ Merge images + signature into entity
      final vendorWithMedia = event.vendor.copyWith(
        frontimages: event.frontimages,
        backimages: event.backimages,
        signature: event.signature,
      );

      final vendor = await createVendorUseCase(vendorWithMedia, event.token);

      // Determine if this was an update or create based on vendorId presence
      final isUpdate =
          event.vendor.vendorId != null && event.vendor.vendorId!.isNotEmpty;
      final successMessage = isUpdate
          ? 'Vendor updated successfully'
          : 'Vendor created successfully';

      emit(VendorFormSuccess(vendor, vendor.message ?? successMessage));
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
