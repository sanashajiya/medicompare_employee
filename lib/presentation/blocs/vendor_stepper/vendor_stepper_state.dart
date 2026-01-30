class VendorStepperState {
  final int currentSection;
  final List<bool> sectionValidations;
  final List<bool> sectionCompleted;
  final List<bool> sectionExpanded;

  static const int totalSections = 6;

  const VendorStepperState({
    this.currentSection = 0,
    this.sectionValidations = const [false, false, false, false, false, false],
    this.sectionCompleted = const [false, false, false, false, false, false],
    this.sectionExpanded = const [true, false, false, false, false, false],
  });

  bool get isFirstSection => currentSection == 0;
  bool get isLastSection => currentSection == totalSections - 1;
  bool get canProceed => sectionValidations[currentSection];

  bool isSectionEnabled(int index) {
    if (index == 0) return true;
    return sectionCompleted[index - 1] || index <= currentSection;
  }

  VendorStepperState copyWith({
    int? currentSection,
    List<bool>? sectionValidations,
    List<bool>? sectionCompleted,
    List<bool>? sectionExpanded,
  }) {
    return VendorStepperState(
      currentSection: currentSection ?? this.currentSection,
      sectionValidations: sectionValidations ?? this.sectionValidations,
      sectionCompleted: sectionCompleted ?? this.sectionCompleted,
      sectionExpanded: sectionExpanded ?? this.sectionExpanded,
    );
  }
}






