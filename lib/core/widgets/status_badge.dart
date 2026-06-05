import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tom semântico do badge.
enum StatusTone { neutral, info, success, warning, danger }

/// Badge compacto para representar status (ex.: Pendente, Aprovada, Paga).
/// O tom define as cores; o texto é livre.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _colors(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return (AppColors.success, AppColors.successSoft);
      case StatusTone.warning:
        return (AppColors.warning, AppColors.warningSoft);
      case StatusTone.danger:
        return (AppColors.error, AppColors.errorSoft);
      case StatusTone.info:
        return (AppColors.info, AppColors.infoSoft);
      case StatusTone.neutral:
        return (AppColors.textSecondary, AppColors.surfaceMuted);
    }
  }
}
