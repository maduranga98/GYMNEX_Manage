import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class MiniColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;
  final double size;

  const MiniColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMiniColorPicker(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.inputBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: selectedColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  void _showMiniColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Select Color', style: AppTypography.h3),
            content: SizedBox(
              width: 250,
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _getQuickColors().length,
                itemBuilder: (context, index) {
                  final color = _getQuickColors()[index];
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

  List<Color> _getQuickColors() {
    return [
      const Color(0xFFE63946), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFFD700), // Gold
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF212121), // Dark Grey
      const Color(0xFF424242), // Grey
      const Color(0xFF757575), // Medium Grey
      const Color(0xFFBDBDBD), // Light Grey
      const Color(0xFFFFFFFF), // White
      const Color(0xFF000000), // Black
    ];
  }
}
