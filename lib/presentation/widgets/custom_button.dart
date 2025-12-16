import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    
    Widget buttonChild;
    if (isLoading) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      buttonChild = Text(text);
    }
    
    return SizedBox(
      width: width,
      child: _buildButton(context, buttonChild, isEnabled),
    );
  }
  
  Widget _buildButton(BuildContext context, Widget child, bool isEnabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppColors.primary : AppColors.buttonDisabled,
            foregroundColor: isEnabled ? Colors.white : AppColors.buttonTextDisabled,
          ),
          child: child,
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppColors.secondary : AppColors.buttonDisabled,
            foregroundColor: isEnabled ? Colors.white : AppColors.buttonTextDisabled,
          ),
          child: child,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: isEnabled ? AppColors.primary : AppColors.buttonTextDisabled,
            side: BorderSide(
              color: isEnabled ? AppColors.primary : AppColors.buttonDisabled,
              width: 2,
            ),
          ),
          child: child,
        );
    }
  }
}

