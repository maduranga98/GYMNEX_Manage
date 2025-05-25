import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/data/preset_color_schemes.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class PresetColorSchemeSelector extends StatelessWidget {
  final GymColorScheme selectedScheme;
  final Function(GymColorScheme) onSchemeSelected;

  const PresetColorSchemeSelector({
    super.key,
    required this.selectedScheme,
    required this.onSchemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: PresetColorSchemes.presets.length,
            itemBuilder: (context, index) {
              final scheme = PresetColorSchemes.presets[index];
              final isSelected = scheme.name == selectedScheme.name;

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => onSchemeSelected(scheme),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.accentColor
                                : AppColors.inputBorder,
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
                        // Color preview
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: scheme.backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Card sample
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: scheme.cardColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 60,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: scheme.headingColor,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Accent color indicator
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: scheme.accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Name
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            scheme.name,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
