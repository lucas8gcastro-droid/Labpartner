import 'package:supabase_flutter/supabase_flutter.dart';

/// Converte exceções do Supabase em mensagens claras em português para a UI.
String friendlyError(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('user already registered') || msg.contains('already been registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('password should be at least')) {
      return 'A senha é muito curta.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Muitas tentativas. Aguarde alguns instantes.';
    }
    return error.message;
  }

  if (error is PostgrestException) {
    return error.message;
  }

  return 'Algo deu errado. Tente novamente.';
}
