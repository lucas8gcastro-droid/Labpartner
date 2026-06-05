import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

part 'auth_controller.g.dart';

/// Stream das mudanças de autenticação. Outros providers observam isto para
/// reagir a login/logout.
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Perfil de negócio do usuário logado (null se deslogado).
///
/// Recarrega automaticamente sempre que o estado de autenticação muda.
@riverpod
Future<AppUser?> currentUser(Ref ref) async {
  // Recria quando a autenticação muda.
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).fetchCurrentProfile();
}

/// Controller das ações de autenticação.
///
/// Expõe um `AsyncValue<void>` que a UI observa para mostrar loading e erros.
/// A navegação NÃO é feita aqui — quem cuida disso é o redirect do GoRouter,
/// que reage à mudança de sessão.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email.trim(), password: password),
    );
  }

  /// Retorna `true` se o usuário já está autenticado, `false` se precisa
  /// confirmar o e-mail. Lança em caso de erro (capturado pela UI).
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
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _repo.signUp(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        phone: phone,
        university: university,
        course: course,
        semester: semester,
        pixKey: pixKey,
      ),
    );
    state = result.whenData((_) {});
    if (result.hasError) throw result.error!;
    return result.value ?? false;
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.resetPassword(email.trim()));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.signOut);
  }
}
