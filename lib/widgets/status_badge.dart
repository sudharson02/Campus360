import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.infoBg;
    Color fg = AppColors.info;

    final lower = status.toLowerCase();
    if (lower == 'resolved' || lower == 'present' || lower == 'completed' || lower == 'available') {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (lower == 'pending' || lower == 'waiting' || lower == 'in progress') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
    } else if (lower == 'rejected' || lower == 'absent' || lower == 'skipped') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
    } else if (lower == 'serving') {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
