import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/branding.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget raiz da aplicação.
///
/// Liga o tema global e o GoRouter (que vem de um provider, para o redirect
/// reagir à autenticação). O nome exibido vem de [Branding], mantendo o
/// rebranding centralizado.
class LabPartnerApp extends ConsumerWidget {
  const LabPartnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: Branding.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
