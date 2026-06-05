import '../../../shared/models/enums.dart';

/// Resumo agregado exibido no dashboard do representante.
///
/// É um "view model" de leitura: combina contagens de cotações por status e
/// totais de comissão em um único objeto imutável, para a UI consumir sem
/// fazer contas. Não é serializado — vem montado pelo repositório.
class DashboardSummary {
  const DashboardSummary({
    required this.quotesByStatus,
    required this.totalQuotes,
    required this.totalCommission,
    required this.pendingCommission,
    required this.paidCommission,
  });

  /// Quantidade de cotações em cada status.
  final Map<QuoteStatus, int> quotesByStatus;

  /// Total de cotações do representante (todas as situações).
  final int totalQuotes;

  /// Soma de TODAS as comissões geradas (independente de pagamento).
  final double totalCommission;

  /// Comissões ainda a receber (status de pagamento pendente).
  final double pendingCommission;

  /// Comissões já pagas.
  final double paidCommission;

  /// Estado vazio (usado como fallback antes de carregar dados).
  factory DashboardSummary.empty() => const DashboardSummary(
        quotesByStatus: {},
        totalQuotes: 0,
        totalCommission: 0,
        pendingCommission: 0,
        paidCommission: 0,
      );

  int countFor(QuoteStatus status) => quotesByStatus[status] ?? 0;

  int get pendingQuotes => countFor(QuoteStatus.pending);
  int get approvedQuotes => countFor(QuoteStatus.approved);
  int get deliveredQuotes => countFor(QuoteStatus.delivered);
}
