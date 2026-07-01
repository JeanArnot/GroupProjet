import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BadgeType { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.success:
        return AppColors.success.withOpacity(0.15);
      case BadgeType.warning:
        return AppColors.warning.withOpacity(0.15);
      case BadgeType.danger:
        return AppColors.danger.withOpacity(0.15);
      case BadgeType.info:
        return AppColors.info.withOpacity(0.15);
      case BadgeType.neutral:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.danger:
        return AppColors.danger;
      case BadgeType.info:
        return AppColors.info;
      case BadgeType.neutral:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
