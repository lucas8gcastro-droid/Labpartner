/// Configuração de acesso ao Supabase.
///
/// As credenciais NÃO ficam no código-fonte. Elas são injetadas em tempo de
/// compilação via `--dart-define`. Exemplo ao rodar o app:
///
/// flutter run \
///   --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sua_anon_key
///
/// Para times, prefira um arquivo `--dart-define-from-file=env.json`.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Valida que as variáveis foram fornecidas. Chamado no bootstrap do app.
  static void assertConfigured() {
    assert(
      url.isNotEmpty && anonKey.isNotEmpty,
      'SUPABASE_URL e SUPABASE_ANON_KEY precisam ser passados via --dart-define. '
      'Veja a documentação em lib/core/config/supabase_config.dart.',
    );
  }
}
