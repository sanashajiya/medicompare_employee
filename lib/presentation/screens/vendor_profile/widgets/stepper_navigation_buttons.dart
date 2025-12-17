import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StepperNavigationButtons extends StatelessWidget {
  final bool isFirstSection;
  final bool isLastSection;
  final bool canProceed;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const StepperNavigationButtons({
    super.key,
    required this.isFirstSection,
    required this.isLastSection,
    required this.canProceed,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirstSection)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back_ios_rounded, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          if (!isFirstSection) const SizedBox(width: 12),
          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed && !isSubmitting
                  ? (isLastSection ? onSubmit : onNext)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastSection
                    ? AppColors.success
                    : AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.buttonDisabled,
                disabledForegroundColor: AppColors.buttonTextDisabled,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: canProceed ? 1 : 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastSection ? 'Submit' : 'Next',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isLastSection
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
