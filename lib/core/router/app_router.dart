import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/dashboard/presentation/representative_dashboard_page.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

part 'app_router.g.dart';

/// Router central da aplicação.
///
/// A navegação por autenticação é resolvida AQUI, no `redirect`, e não nos
/// controllers — eles apenas mudam o estado da sessão. Quando a sessão muda,
/// o `refreshListenable` faz o GoRouter reavaliar o redirect e levar o usuário
/// ao destino correto (dashboard ao logar, login ao deslogar).
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // O repositório é keepAlive e estável; lemos a sessão direto dele.
  final authRepository = ref.watch(authRepositoryProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    // Reavalia o redirect a cada evento de autenticação (login/logout/refresh).
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final loggedIn = authRepository.currentSession != null;
      final onPublicRoute =
          AppRoutes.publicPaths.contains(state.matchedLocation);

      // Sem sessão tentando acessar área logada -> manda para o login.
      if (!loggedIn && !onPublicRoute) return AppRoutes.login;

      // Já logado tentando ver login/cadastro -> manda para o dashboard.
      if (loggedIn && onPublicRoute) return AppRoutes.dashboard;

      // Caso contrário, segue para a rota pedida.
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // NOTA: o roteamento por papel (admin x representante) será adicionado
      // quando o painel administrativo entrar. Por ora, todos os usuários
      // autenticados caem no dashboard do representante.
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const RepresentativeDashboardPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}
