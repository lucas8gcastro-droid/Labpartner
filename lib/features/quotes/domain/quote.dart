import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/enums.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

/// Cotação (espelha a tabela public.quotes).
/// Os itens vivem em `quote_items` e são carregados separadamente.
@freezed
class Quote with _$Quote {
  const Quote._();

  const factory Quote({
    required String id,
    @JsonKey(name: 'quote_number') String? quoteNumber,
    @JsonKey(name: 'representative_id') required String representativeId,
    @JsonKey(name: 'professor_name') required String professorName,
    String? laboratory,
    String? department,
    String? university,
    String? observations,
    @Default(UrgencyLevel.normal) UrgencyLevel urgency,
    @Default(QuoteStatus.pending) QuoteStatus status,
    @JsonKey(name: 'total_amount') @Default(0) double totalAmount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  String get displayNumber => quoteNumber ?? '—';
}
