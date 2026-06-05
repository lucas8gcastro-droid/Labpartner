import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/enums.dart';
import '../domain/dashboard_summary.dart';

part 'dashboard_repository.g.dart';

/// Acesso aos dados que alimentam o dashboard do representante.
///
/// Faz consultas enxutas (apenas as colunas necessárias) filtradas pelo
/// representante logado, e a agregação acontece no cliente. Para volumes
/// maiores, este é o ponto natural para migrar a contagem para uma view/RPC
/// no Postgres sem mexer na UI.
class DashboardRepository {
  DashboardRepository(this._client);

  final SupabaseClient _client;

  /// Monta o resumo do representante atual. As políticas de RLS já restringem
  /// as linhas ao próprio usuário, então o filtro por id é redundante em termos
  /// de segurança — mas o mantemos explícito por clareza e performance.
  Future<DashboardSummary> fetchSummary() async {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return DashboardSummary.empty();

    // Cotações: só precisamos do status para contar.
    final quoteRows = await _client
        .from('quotes')
        .select('status')
        .eq('representative_id', userId);

    final quotesByStatus = <QuoteStatus, int>{};
    for (final row in quoteRows) {
      final status = _parseQuoteStatus(row['status'] as String?);
      if (status == null) continue;
      quotesByStatus.update(status, (n) => n + 1, ifAbsent: () => 1);
    }
    final totalQuotes = quoteRows.length;

    // Comissões: valor + status de pagamento.
    final commissionRows = await _client
        .from('commissions')
        .select('commission_amount, payment_status')
        .eq('representative_id', userId);

    double total = 0;
    double pending = 0;
    double paid = 0;
    for (final row in commissionRows) {
      // numeric do Postgres chega como num; toDouble é seguro.
      final amount = (row['commission_amount'] as num?)?.toDouble() ?? 0;
      total += amount;
      final isPaid = (row['payment_status'] as String?) == 'paid';
      if (isPaid) {
        paid += amount;
      } else {
        pending += amount;
      }
    }

    return DashboardSummary(
      quotesByStatus: quotesByStatus,
      totalQuotes: totalQuotes,
      totalCommission: total,
      pendingCommission: pending,
      paidCommission: paid,
    );
  }

  QuoteStatus? _parseQuoteStatus(String? raw) {
    switch (raw) {
      case 'pending':
        return QuoteStatus.pending;
      case 'approved':
        return QuoteStatus.approved;
      case 'rejected':
        return QuoteStatus.rejected;
      case 'delivered':
        return QuoteStatus.delivered;
      default:
        return null;
    }
  }
}

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepository(Supabase.instance.client);
}
