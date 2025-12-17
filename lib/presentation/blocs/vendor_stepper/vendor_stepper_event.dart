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
