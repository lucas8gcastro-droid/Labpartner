import 'package:json_annotation/json_annotation.dart';

import '../../core/widgets/status_badge.dart';

/// Enums do domínio.
///
/// Os valores `@JsonValue` correspondem EXATAMENTE aos enums do Postgres
/// (ver migration 0001). Os getters de rótulo fornecem o texto em português
/// para a UI, mantendo o banco em inglês (estável) e a interface localizada.

// ----------------------------------------------------------------------------
// Papel do usuário
// ----------------------------------------------------------------------------
enum UserRole {
  @JsonValue('representative')
  representative,
  @JsonValue('admin')
  admin;

  String get label => switch (this) {
        UserRole.representative => 'Representante',
        UserRole.admin => 'Administrador',
      };

  bool get isAdmin => this == UserRole.admin;
}

// ----------------------------------------------------------------------------
// Categoria de produto
// ----------------------------------------------------------------------------
enum ProductCategory {
  @JsonValue('solvent')
  solvent,
  @JsonValue('reagent')
  reagent,
  @JsonValue('acid')
  acid,
  @JsonValue('base')
  base,
  @JsonValue('lab_supply')
  labSupply;

  String get label => switch (this) {
        ProductCategory.solvent => 'Solventes',
        ProductCategory.reagent => 'Reagentes',
        ProductCategory.acid => 'Ácidos',
        ProductCategory.base => 'Bases',
        ProductCategory.labSupply => 'Laboratoriais',
      };
}

// ----------------------------------------------------------------------------
// Status da cotação
// ----------------------------------------------------------------------------
enum QuoteStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('delivered')
  delivered;

  String get label => switch (this) {
        QuoteStatus.pending => 'Pendente',
        QuoteStatus.approved => 'Aprovada',
        QuoteStatus.rejected => 'Recusada',
        QuoteStatus.delivered => 'Entregue',
      };

  StatusTone get tone => switch (this) {
        QuoteStatus.pending => StatusTone.warning,
        QuoteStatus.approved => StatusTone.info,
        QuoteStatus.rejected => StatusTone.danger,
        QuoteStatus.delivered => StatusTone.success,
      };
}

// ----------------------------------------------------------------------------
// Urgência
// ----------------------------------------------------------------------------
enum UrgencyLevel {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high;

  String get label => switch (this) {
        UrgencyLevel.low => 'Baixa',
        UrgencyLevel.normal => 'Normal',
        UrgencyLevel.high => 'Alta',
      };
}

// ----------------------------------------------------------------------------
// Status de pagamento da comissão
// ----------------------------------------------------------------------------
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid;

  String get label => switch (this) {
        PaymentStatus.pending => 'A pagar',
        PaymentStatus.paid => 'Paga',
      };

  StatusTone get tone => switch (this) {
        PaymentStatus.pending => StatusTone.warning,
        PaymentStatus.paid => StatusTone.success,
      };
}
