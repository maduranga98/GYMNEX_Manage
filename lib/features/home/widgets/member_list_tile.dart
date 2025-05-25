import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class MemberListTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String subtitle;
  final String? trailingText;
  final Color? trailingColor;
  final VoidCallback onTap;

  const MemberListTile({
    super.key,
    required this.name,
    this.imageUrl,
    required this.subtitle,
    this.trailingText,
    this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryColor,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child:
              imageUrl == null
                  ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        title: Text(
          name,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing:
            trailingText != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (trailingColor ?? AppColors.accentColor).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailingText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: trailingColor ?? AppColors.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
