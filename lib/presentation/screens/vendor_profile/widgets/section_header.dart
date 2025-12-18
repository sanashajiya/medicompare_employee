import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isExpanded;
  final bool isCompleted;
  final bool isEnabled;
  final bool isActive;
  final VoidCallback onTap;

  const SectionHeader({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.isCompleted,
    required this.isEnabled,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isCompleted
        ? AppColors.success
        : isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isExpanded
              ? primaryColor.withOpacity(0.06)
              : isEnabled
              ? Colors.white
              : AppColors.background,
          border: Border(
            left: BorderSide(
              color: isExpanded
                  ? primaryColor
                  : isCompleted
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.border,
              width: isExpanded ? 3 : 2,
            ),
            bottom: BorderSide(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Step number / check indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : isExpanded
                    ? AppColors.primary
                    : isEnabled
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.border.withOpacity(0.3),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isExpanded
                              ? Colors.white
                              : isEnabled
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Icon
            Icon(
              icon,
              color: isEnabled ? primaryColor : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 10),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                  color: isEnabled ? AppColors.textPrimary : AppColors.textHint,
                ),
              ),
            ),
            // Expand/Collapse icon
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isEnabled ? primaryColor : AppColors.textHint,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


