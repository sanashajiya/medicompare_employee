abstract class VendorStepperEvent {}

class VendorStepperSectionTapped extends VendorStepperEvent {
  final int sectionIndex;
  VendorStepperSectionTapped(this.sectionIndex);
}

class VendorStepperNextPressed extends VendorStepperEvent {}

class VendorStepperPreviousPressed extends VendorStepperEvent {}

class VendorStepperSectionValidated extends VendorStepperEvent {
  final int sectionIndex;
  final bool isValid;
  VendorStepperSectionValidated(this.sectionIndex, this.isValid);
}

class VendorStepperReset extends VendorStepperEvent {}

class VendorStepperRestoreState extends VendorStepperEvent {
  final int currentSection;
  final List<bool> sectionValidations;
  final List<bool> sectionCompleted;
  final List<bool> sectionExpanded;

  VendorStepperRestoreState({
    required this.currentSection,
    required this.sectionValidations,
    required this.sectionCompleted,
    required this.sectionExpanded,
  });
}
