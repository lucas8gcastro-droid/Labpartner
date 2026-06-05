import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_user.dart';

part 'auth_repository.g.dart';

/// Fonte única de acesso à autenticação e ao perfil do usuário.
///
/// Mantém toda a dependência do Supabase isolada aqui — controllers e UI
/// nunca falam com o `SupabaseClient` diretamente.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Sessão atual (null se deslogado).
  Session? get currentSession => _client.auth.currentSession;

  /// Stream de mudanças de autenticação (login/logout/refresh).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Login por e-mail e senha.
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Cadastro. Os metadados são lidos pelo trigger `handle_new_user`
  /// no banco, que cria a linha em public.users automaticamente.
  ///
  /// Retorna `true` se já há sessão ativa (confirmação de e-mail desabilitada)
  /// ou `false` se o usuário precisa confirmar o e-mail antes de entrar.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? university,
    String? course,
    String? semester,
    String? pixKey,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (university != null) 'university': university,
        if (course != null) 'course': course,
        if (semester != null) 'semester': semester,
        if (pixKey != null) 'pix_key': pixKey,
        'role': 'representative',
      },
    );
    return res.session != null;
  }

  /// Envia e-mail de recuperação de senha.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Carrega o perfil de negócio do usuário logado.
  Future<AppUser?> fetchCurrentProfile() async {
    final userId = currentSession?.user.id;
    if (userId == null) return null;

    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return AppUser.fromJson(data);
  }
}

/// Provider do repositório de autenticação.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}
