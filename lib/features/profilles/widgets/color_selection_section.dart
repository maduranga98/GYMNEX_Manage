import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/data/preset_color_schemes.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

import 'color_picker_widget.dart';
import 'preset_color_scheme_selector.dart';
import 'color_preview_card.dart';

class ColorSelectionSection extends StatefulWidget {
  final GymColorScheme initialColorScheme;
  final Function(GymColorScheme) onColorSchemeChanged;

  const ColorSelectionSection({
    super.key,
    required this.initialColorScheme,
    required this.onColorSchemeChanged,
  });

  @override
  State<ColorSelectionSection> createState() => _ColorSelectionSectionState();
}

class _ColorSelectionSectionState extends State<ColorSelectionSection> {
  late GymColorScheme _currentScheme;
  bool _isCustomizing = false;

  @override
  void initState() {
    super.initState();
    _currentScheme = widget.initialColorScheme;
  }

  void _updateScheme(GymColorScheme newScheme) {
    setState(() {
      _currentScheme = newScheme;
      _isCustomizing =
          !PresetColorSchemes.presets.any(
            (preset) => preset.name == newScheme.name,
          );
    });
    widget.onColorSchemeChanged(_currentScheme);
  }

  void _updateColor(String colorType, Color color) {
    late GymColorScheme updatedScheme;

    switch (colorType) {
      case 'background':
        updatedScheme = _currentScheme.copyWith(
          backgroundColor: color,
          name: 'Custom',
        );
        break;
      case 'card':
        updatedScheme = _currentScheme.copyWith(
          cardColor: color,
          name: 'Custom',
        );
        break;
      case 'primaryText':
        updatedScheme = _currentScheme.copyWith(
          primaryTextColor: color,
          name: 'Custom',
        );
        break;
      case 'secondaryText':
        updatedScheme = _currentScheme.copyWith(
          secondaryTextColor: color,
          name: 'Custom',
        );
        break;
      case 'heading':
        updatedScheme = _currentScheme.copyWith(
          headingColor: color,
          name: 'Custom',
        );
        break;
      case 'accent':
        updatedScheme = _currentScheme.copyWith(
          accentColor: color,
          name: 'Custom',
        );
        break;
      case 'button':
        updatedScheme = _currentScheme.copyWith(
          buttonColor: color,
          name: 'Custom',
        );
        break;
      case 'border':
        updatedScheme = _currentScheme.copyWith(
          borderColor: color,
          name: 'Custom',
        );
        break;
      default:
        return;
    }

    _updateScheme(updatedScheme);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR CUSTOMIZATION',
          style: AppTypography.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),

        Text(
          'Choose from presets or customize individual colors to match your gym\'s brand.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 24),

        // Preset selector
        PresetColorSchemeSelector(
          selectedScheme: _currentScheme,
          onSchemeSelected: _updateScheme,
        ),

        const SizedBox(height: 32),

        // Preview
        Text(
          'Preview',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ColorPreviewCard(colorScheme: _currentScheme),

        const SizedBox(height: 32),

        // Custom color controls
        ExpansionTile(
          title: Text(
            'Advanced Color Customization',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Fine-tune individual colors',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          backgroundColor: AppColors.cardBackground,
          collapsedBackgroundColor: AppColors.cardBackground,
          childrenPadding: const EdgeInsets.all(20),
          children: [
            _buildColorSection('Background & Layout', [
              ColorPickerWidget(
                label: 'Background Color',
                selectedColor: _currentScheme.backgroundColor,
                onColorChanged: (color) => _updateColor('background', color),
                description: 'Main background color of your profile',
              ),
              const SizedBox(height: 24),
              ColorPickerWidget(
                label: 'Card Color',
                selectedColor: _currentScheme.cardColor,
                onColorChanged: (color) => _updateColor('card', color),
                description: 'Background color for content cards',
              ),
              const SizedBox(height: 24),
              ColorPickerWidget(
                label: 'Border Color',
                selectedColor: _currentScheme.borderColor,
                onColorChanged: (color) => _updateColor('border', color),
                description: 'Color for borders and dividers',
              ),
            ]),

            const SizedBox(height: 32),

            _buildColorSection('Text Colors', [
              ColorPickerWidget(
                label: 'Heading Color',
                selectedColor: _currentScheme.headingColor,
                onColorChanged: (color) => _updateColor('heading', color),
                description: 'Color for main headings and titles',
              ),
              const SizedBox(height: 24),
              ColorPickerWidget(
                label: 'Primary Text',
                selectedColor: _currentScheme.primaryTextColor,
                onColorChanged: (color) => _updateColor('primaryText', color),
                description: 'Main text content color',
              ),
              const SizedBox(height: 24),
              ColorPickerWidget(
                label: 'Secondary Text',
                selectedColor: _currentScheme.secondaryTextColor,
                onColorChanged: (color) => _updateColor('secondaryText', color),
                description: 'Subtitles and descriptions color',
              ),
            ]),

            const SizedBox(height: 32),

            _buildColorSection('Interactive Elements', [
              ColorPickerWidget(
                label: 'Accent Color',
                selectedColor: _currentScheme.accentColor,
                onColorChanged: (color) => _updateColor('accent', color),
                description: 'Primary brand color for highlights',
              ),
              const SizedBox(height: 24),
              ColorPickerWidget(
                label: 'Button Color',
                selectedColor: _currentScheme.buttonColor,
                onColorChanged: (color) => _updateColor('button', color),
                description: 'Color for buttons and call-to-action elements',
              ),
            ]),

            const SizedBox(height: 24),

            // Reset to default button
            if (_isCustomizing) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _updateScheme(PresetColorSchemes.presets.first);
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.accentColor),
                  label: Text(
                    'Reset to Default',
                    style: AppTypography.button.copyWith(
                      color: AppColors.accentColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.accentColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildColorSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
