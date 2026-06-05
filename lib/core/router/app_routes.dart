/// Rotas da aplicação em um único lugar.
///
/// Centralizar os caminhos e nomes evita strings mágicas espalhadas e facilita
/// renomear ou reorganizar a navegação. As telas referenciam `AppRoutes.x`
/// em vez de digitar `/algum-caminho`.
class AppRoutes {
  const AppRoutes._();

  // Caminhos (paths) ----------------------------------------------------------
  static const String login = '/login';
  static const String register = '/cadastro';
  static const String forgotPassword = '/recuperar-senha';
  static const String dashboard = '/dashboard';

  // Nomes (names) — usados em context.goNamed/pushNamed quando preferível.
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgot-password';
  static const String dashboardName = 'dashboard';

  /// Conjunto de rotas públicas (acessíveis sem sessão). Usado pelo redirect
  /// do GoRouter para decidir quando mandar o usuário para o login.
  static const Set<String> publicPaths = {login, register, forgotPassword};
}
