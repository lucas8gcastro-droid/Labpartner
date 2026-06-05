import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/enums.dart';

part 'commission.freezed.dart';
part 'commission.g.dart';

/// Comissão gerada por cotação aprovada (espelha a tabela public.commissions).
/// `commissionAmount` é coluna gerada no banco; só leitura.
@freezed
class Commission with _$Commission {
  const Commission._();

  const factory Commission({
    required String id,
    @JsonKey(name: 'quote_id') required String quoteId,
    @JsonKey(name: 'representative_id') required String representativeId,
    @JsonKey(name: 'total_amount') @Default(0) double totalAmount,
    @Default(0.1) double percentage,
    @JsonKey(name: 'commission_amount') @Default(0) double commissionAmount,
    @JsonKey(name: 'payment_status') @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
  }) = _Commission;

  factory Commission.fromJson(Map<String, dynamic> json) => _$CommissionFromJson(json);

  bool get isPaid => paymentStatus == PaymentStatus.paid;
}
