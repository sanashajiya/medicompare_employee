import 'package:flutter_bloc/flutter_bloc.dart';
import 'vendor_stepper_event.dart';
import 'vendor_stepper_state.dart';

class VendorStepperBloc extends Bloc<VendorStepperEvent, VendorStepperState> {
  VendorStepperBloc() : super(const VendorStepperState()) {
    on<VendorStepperSectionTapped>(_onSectionTapped);
    on<VendorStepperNextPressed>(_onNextPressed);
    on<VendorStepperPreviousPressed>(_onPreviousPressed);
    on<VendorStepperSectionValidated>(_onSectionValidated);
    on<VendorStepperReset>(_onReset);
    on<VendorStepperRestoreState>(_onRestoreState);
  }

  void _onSectionTapped(
    VendorStepperSectionTapped event,
    Emitter<VendorStepperState> emit,
  ) {
    final index = event.sectionIndex;

    // Check if section is enabled
    if (!state.isSectionEnabled(index)) return;

    final newExpanded = List<bool>.from(state.sectionExpanded);

    // Toggle the tapped section
    newExpanded[index] = !newExpanded[index];

    // Update current section if expanding
    int newCurrentSection = state.currentSection;
    if (newExpanded[index]) {
      newCurrentSection = index;
    }

    emit(
      state.copyWith(
        currentSection: newCurrentSection,
        sectionExpanded: newExpanded,
      ),
    );
  }

  void _onNextPressed(
    VendorStepperNextPressed event,
    Emitter<VendorStepperState> emit,
  ) {
    if (state.canProceed && !state.isLastSection) {
      final newCompleted = List<bool>.from(state.sectionCompleted);
      final newExpanded = List<bool>.from(state.sectionExpanded);

      newCompleted[state.currentSection] = true;
      newExpanded[state.currentSection] = false;
      newExpanded[state.currentSection + 1] = true;

      emit(
        state.copyWith(
          currentSection: state.currentSection + 1,
          sectionCompleted: newCompleted,
          sectionExpanded: newExpanded,
        ),
      );
    }
  }

  void _onPreviousPressed(
    VendorStepperPreviousPressed event,
    Emitter<VendorStepperState> emit,
  ) {
    if (!state.isFirstSection) {
      final newExpanded = List<bool>.from(state.sectionExpanded);
      newExpanded[state.currentSection] = false;
      newExpanded[state.currentSection - 1] = true;

      emit(
        state.copyWith(
          currentSection: state.currentSection - 1,
          sectionExpanded: newExpanded,
        ),
      );
    }
  }

  void _onSectionValidated(
    VendorStepperSectionValidated event,
    Emitter<VendorStepperState> emit,
  ) {
    final newValidations = List<bool>.from(state.sectionValidations);
    newValidations[event.sectionIndex] = event.isValid;
    emit(state.copyWith(sectionValidations: newValidations));
  }

  void _onReset(VendorStepperReset event, Emitter<VendorStepperState> emit) {
    emit(const VendorStepperState());
  }

  void _onRestoreState(
    VendorStepperRestoreState event,
    Emitter<VendorStepperState> emit,
  ) {
    emit(
      state.copyWith(
        currentSection: event.currentSection,
        sectionValidations: event.sectionValidations,
        sectionCompleted: event.sectionCompleted,
        sectionExpanded: event.sectionExpanded,
      ),
    );
  }
}

