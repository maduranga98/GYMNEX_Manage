// File: lib/features/profilles/widgets/color_preview_card.dart
import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';

class ColorPreviewCard extends StatelessWidget {
  final GymColorScheme colorScheme;

  const ColorPreviewCard({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Increased height to accommodate content
      decoration: BoxDecoration(
        color: colorScheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Preview',
              style: AppTypography.h3.copyWith(
                color: colorScheme.headingColor,
                fontSize: 16, // Reduced font size
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            // Card sample
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: colorScheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Gym Name',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Expanded(
                      child: Text(
                        'This is how your description text will look with the selected colors.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.secondaryTextColor,
                          fontSize: 12, // Reduced font size
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    // Sample button
                    Container(
                      width: double.infinity,
                      height: 32, // Reduced button height
                      decoration: BoxDecoration(
                        color: colorScheme.buttonColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'SAMPLE BUTTON',
                          style: AppTypography.button.copyWith(
                            color: _getContrastColor(colorScheme.buttonColor),
                            fontSize: 10, // Reduced font size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
