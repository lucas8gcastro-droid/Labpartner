import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_controller.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

part 'dashboard_providers.g.dart';

/// Resumo do dashboard do representante logado.
///
/// Recarrega automaticamente quando a autenticação muda (login/logout),
/// garantindo que os números sempre reflitam o usuário atual. A UI consome
/// isto como um `AsyncValue` (loading / erro / dados).
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) async {
  // Reage a mudanças de sessão.
  ref.watch(authStateChangesProvider);
  return ref.watch(dashboardRepositoryProvider).fetchSummary();
}
