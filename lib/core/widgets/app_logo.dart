import 'package:flutter/material.dart';

import '../config/branding.dart';
import '../theme/app_colors.dart';

/// Marca do app: ícone em "container" + wordmark.
///
/// Como o branding é provisório, o nome vem de [Branding]. Trocar a marca não
/// exige alterar telas.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});

  /// Quando true, mostra apenas o símbolo (sem o texto).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mark = Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.science_outlined, color: Colors.white, size: 20),
    );

    if (compact) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          Branding.appName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
