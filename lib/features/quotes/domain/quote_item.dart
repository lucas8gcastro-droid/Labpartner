import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_item.freezed.dart';
part 'quote_item.g.dart';

/// Item de uma cotação (espelha a tabela public.quote_items).
/// `lineTotal` é calculado no banco (coluna gerada); só leitura.
@freezed
class QuoteItem with _$QuoteItem {
  const QuoteItem._();

  const factory QuoteItem({
    required String id,
    @JsonKey(name: 'quote_id') required String quoteId,
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'line_total') @Default(0) double lineTotal,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _QuoteItem;

  factory QuoteItem.fromJson(Map<String, dynamic> json) => _$QuoteItemFromJson(json);
}
