import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final String? errorText;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  
  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.errorText,
    required this.items,
    this.onChanged,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint ?? 'Select $label'),
          isExpanded: true,
          decoration: InputDecoration(
            errorText: errorText,
            enabled: enabled,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

