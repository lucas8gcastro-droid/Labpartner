import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

/// Ponto de entrada da aplicação.
///
/// Ordem do bootstrap:
/// 1. inicializa o binding do Flutter;
/// 2. valida as credenciais do Supabase (passadas via --dart-define);
/// 3. carrega os dados de localização pt_BR (datas/moeda);
/// 4. inicializa o cliente Supabase;
/// 5. sobe o app dentro do ProviderScope (necessário para o Riverpod).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Falha cedo (em debug) se SUPABASE_URL / SUPABASE_ANON_KEY não vierem.
  SupabaseConfig.assertConfigured();

  // Necessário antes de usar DateFormat com locale 'pt_BR' (ver Formatters).
  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: LabPartnerApp(),
    ),
  );
}
