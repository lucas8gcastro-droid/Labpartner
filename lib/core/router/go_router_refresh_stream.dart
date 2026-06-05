import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapta um [Stream] para o `refreshListenable` do GoRouter.
///
/// O GoRouter reavalia o `redirect` sempre que o listenable notifica. Aqui
/// transformamos a stream de autenticação do Supabase em notificações, de modo
/// que login/logout disparem a reavaliação das rotas automaticamente.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Notifica uma vez no início para o redirect rodar com o estado atual.
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
