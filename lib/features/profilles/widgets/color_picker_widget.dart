import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/data/preset_color_schemes.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class ColorPickerWidget extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final Function(Color) onColorChanged;
  final String? description;

  const ColorPickerWidget({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onColorChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showColorPicker(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildQuickColorGrid(),
      ],
    );
  }

  Widget _buildQuickColorGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            PresetColorSchemes.quickColors.map((color) {
              final isSelected = color.value == selectedColor.value;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.accentColor
                              : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Select $label', style: AppTypography.h3),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current color display
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Center(
                      child: Text(
                        '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: AppTypography.bodyLarge.copyWith(
                          color: _getContrastColor(selectedColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Color grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _generateColorPalette().length,
                    itemBuilder: (context, index) {
                      final color = _generateColorPalette()[index];
                      return GestureDetector(
                        onTap: () {
                          onColorChanged(color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  color.value == selectedColor.value
                                      ? AppColors.accentColor
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  List<Color> _generateColorPalette() {
    List<Color> colors = [];

    // Add preset colors
    colors.addAll(PresetColorSchemes.quickColors);

    // Add grayscale colors
    for (int i = 0; i <= 255; i += 32) {
      colors.add(Color.fromRGBO(i, i, i, 1));
    }

    // Add more color variations
    final baseColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
    ];

    for (final baseColor in baseColors) {
      for (int shade in [100, 300, 500, 700, 900]) {
        colors.add((baseColor)[shade]!);
      }
    }

    return colors.toSet().toList(); // Remove duplicates
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
