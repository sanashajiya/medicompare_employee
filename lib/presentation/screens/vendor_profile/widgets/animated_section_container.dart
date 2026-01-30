import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedSectionContainer extends StatelessWidget {
  final bool isExpanded;
  final Widget child;

  const AnimatedSectionContainer({
    super.key,
    required this.isExpanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isExpanded
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 3,
                  ),
                  bottom: BorderSide(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}






