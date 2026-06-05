import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/models/enums.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../application/dashboard_providers.dart';
import '../domain/dashboard_summary.dart';
import 'widgets/stat_card.dart';

/// Dashboard inicial do representante.
///
/// Reúne os indicadores que respondem "como vão minhas vendas?": comissões a
/// receber e acumuladas, volume de cotações e a distribuição por status, além
/// da ação principal do MVP — abrir uma nova cotação.
class RepresentativeDashboardPage extends ConsumerWidget {
  const RepresentativeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const AppLogo(),
        actions: [
          _UserMenu(user: userAsync.valueOrNull),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          await ref.read(dashboardSummaryProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(user: userAsync.valueOrNull),
                  const SizedBox(height: AppSpacing.xl),
                  summaryAsync.when(
                    loading: () => const _DashboardLoading(),
                    error: (e, _) => _DashboardError(
                      message: friendlyError(e),
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                    data: (summary) => _DashboardContent(summary: summary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Cabeçalho: saudação + ação principal
// =============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser? user;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user?.firstName;
    final greeting = name == null ? _greeting() : '${_greeting()}, $name';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;

        final texts = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Acompanhe suas cotações e comissões.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

        final action = PrimaryButton(
          label: 'Nova cotação',
          icon: Icons.add,
          expand: isNarrow,
          onPressed: () => _onNewQuote(context),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              texts,
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: texts),
            const SizedBox(width: AppSpacing.lg),
            action,
          ],
        );
      },
    );
  }

  void _onNewQuote(BuildContext context) {
    // TODO: navegar para o fluxo de nova cotação quando ele existir.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Fluxo de nova cotação chega na próxima etapa.'),
        ),
      );
  }
}

// =============================================================================
// Conteúdo com dados carregados
// =============================================================================
class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatGrid(summary: summary),
        const SizedBox(height: AppSpacing.xl),
        _StatusBreakdown(summary: summary),
      ],
    );
  }
}

/// Grade responsiva de cards de métrica.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      StatCard(
        label: 'Comissão a receber',
        value: Formatters.currency(summary.pendingCommission),
        caption: 'aguardando pagamento',
        icon: Icons.account_balance_wallet_outlined,
        accent: AppColors.primary,
        accentSoft: AppColors.primarySoft,
      ),
      StatCard(
        label: 'Comissão acumulada',
        value: Formatters.currency(summary.totalCommission),
        caption: 'total gerado',
        icon: Icons.trending_up,
        accent: AppColors.success,
        accentSoft: AppColors.successSoft,
      ),
      StatCard(
        label: 'Cotações',
        value: summary.totalQuotes.toString(),
        caption: 'no total',
        icon: Icons.description_outlined,
        accent: AppColors.info,
        accentSoft: AppColors.infoSoft,
      ),
      StatCard(
        label: 'Pendentes',
        value: summary.pendingQuotes.toString(),
        caption: 'aguardando análise',
        icon: Icons.hourglass_empty,
        accent: AppColors.warning,
        accentSoft: AppColors.warningSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1040
            ? 4
            : width >= 680
                ? 2
                : 1;

        const gap = AppSpacing.md;
        final itemWidth =
            (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards)
              SizedBox(width: itemWidth, child: card),
          ],
        );
      },
    );
  }
}

/// Painel com a distribuição de cotações por status.
class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status das cotações',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.lg,
            children: [
              for (final status in QuoteStatus.values)
                _StatusTile(
                  status: status,
                  count: summary.countFor(status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.count});

  final QuoteStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        StatusBadge(label: status.label, tone: status.tone),
      ],
    );
  }
}

// =============================================================================
// Estados auxiliares (loading / erro)
// =============================================================================
class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 36, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Menu do usuário (logout)
// =============================================================================
class _UserMenu extends ConsumerWidget {
  const _UserMenu({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final initials = _initials(user?.fullName);

    return PopupMenuButton<String>(
      tooltip: 'Conta',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await ref.read(authControllerProvider.notifier).signOut();
          // O redirect do GoRouter leva ao login automaticamente.
        }
      },
      itemBuilder: (context) => [
        if (user != null)
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user!.fullName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user!.role.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        if (user != null) const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppColors.error),
              SizedBox(width: AppSpacing.sm),
              Text('Sair'),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primarySoft,
        child: Text(
          initials,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '–';
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '–';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
