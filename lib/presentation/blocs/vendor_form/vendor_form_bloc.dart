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
      // Extract clean error message for user display
      String errorMsg = e.toString();

      // Remove "Exception: " prefix
      errorMsg = errorMsg.replaceAll('Exception: ', '');

      // Try to extract message from API error JSON response
      if (errorMsg.contains('"message"')) {
        try {
          final match = RegExp(r'"message":"([^"]+)"').firstMatch(errorMsg);
          if (match != null) {
            errorMsg = match.group(1) ?? errorMsg;
          }
        } catch (_) {}
      }

      // Clean up technical error prefixes
      errorMsg = errorMsg.replaceAll(RegExp(r'API Error:\s*\d+\s*-\s*'), '');
      errorMsg = errorMsg.replaceAll('Network error: ', '');

      // Handle specific common errors with user-friendly messages
      if (errorMsg.toLowerCase().contains('email') &&
          errorMsg.toLowerCase().contains('exist')) {
        errorMsg =
            'This email is already registered. Please use a different email.';
      } else if (errorMsg.toLowerCase().contains('mobile') &&
          errorMsg.toLowerCase().contains('exist')) {
        errorMsg =
            'This mobile number is already registered. Please use a different number.';
      }

      emit(VendorFormFailure(errorMsg));
    }
  }

  void _onVendorFormReset(
    VendorFormReset event,
    Emitter<VendorFormState> emit,
  ) {
    emit(VendorFormInitial());
  }
}
