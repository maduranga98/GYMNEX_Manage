// 1. ADD THIS IMPORT to your setup.dart file:

// 2. CREATE THIS FILE: lib/features/profilles/widgets/color_selection_toggle.dart
import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class ColorSelectionToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ColorSelectionToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.accentColor : AppColors.inputBorder,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.palette,
            color: value ? AppColors.accentColor : AppColors.iconInactive,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Colors',
                  style: AppTypography.bodyLarge.copyWith(
                    color:
                        value ? AppColors.primaryText : AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize your gym profile colors',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentColor,
            inactiveThumbColor: AppColors.mutedText,
            inactiveTrackColor: AppColors.inputBackground,
          ),
        ],
      ),
    );
  }
}
