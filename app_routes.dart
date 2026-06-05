import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';

/// Layout base das telas de autenticação: fundo suave + card centralizado
/// com largura máxima, no estilo de produtos SaaS (Stripe/Linear).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo()),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(title, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(subtitle, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.lg),
                        child,
                      ],
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyMedium ?? const TextStyle(),
                      child: Center(child: footer!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
