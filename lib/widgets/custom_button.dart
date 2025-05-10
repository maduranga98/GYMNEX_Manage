import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = 52.0,
    this.borderRadius = 12.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined
                  ? Colors.transparent
                  : backgroundColor ?? AppColors.buttonColor,
          foregroundColor: textColor ?? AppColors.buttonText,
          elevation: isOutlined ? 0 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side:
                isOutlined
                    ? BorderSide(
                      color: backgroundColor ?? AppColors.buttonColor,
                    )
                    : BorderSide.none,
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? AppColors.accentColor : Colors.white,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: AppTypography.button.copyWith(
                        color:
                            isOutlined
                                ? (textColor ?? AppColors.accentColor)
                                : (textColor ?? AppColors.buttonText),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
