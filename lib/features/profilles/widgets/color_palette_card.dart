import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class ColorPaletteCard extends StatelessWidget {
  final GymColorScheme colorScheme;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorPaletteCard({
    super.key,
    required this.colorScheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentColor : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            // Color swatches
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Card preview
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: colorScheme.headingColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 2,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryTextColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 50,
                              height: 2,
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryTextColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Color dots
                    Positioned(
                      bottom: 4,
                      left: 8,
                      child: Row(
                        children: [
                          _buildColorDot(colorScheme.accentColor),
                          const SizedBox(width: 2),
                          _buildColorDot(colorScheme.buttonColor),
                          const SizedBox(width: 2),
                          _buildColorDot(colorScheme.borderColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Name
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    colorScheme.name,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
