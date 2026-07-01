import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const HealthStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text = label ?? status;

    switch (status.toLowerCase()) {
      case 'healthy':
      case 'on track':
      case 'success':
        color = AppTheme.statusSuccess;
        icon = Icons.check_circle;
        break;
      case 'warning':
      case 'at risk':
        color = AppTheme.statusWarning;
        icon = Icons.warning_amber_rounded;
        break;
      case 'critical':
      case 'needs attention':
      case 'error':
        color = AppTheme.statusError;
        icon = Icons.error_outline;
        break;
      default:
        color = AppTheme.accentTurquoise;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
