import 'package:intl/intl.dart';

/// Formatação localizada (pt_BR) para moeda, percentual e datas.
///
/// Inicialize a localização no bootstrap com:
///   await initializeDateFormatting('pt_BR');
class Formatters {
  const Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dateTime = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');

  /// 1234.5 -> "R$ 1.234,50"
  static String currency(num value) => _currency.format(value);

  /// 0.10 -> "10%"
  static String percent(num fraction) {
    final pct = (fraction * 100);
    final str = pct == pct.roundToDouble() ? pct.toStringAsFixed(0) : pct.toStringAsFixed(1);
    return '$str%';
  }

  static String date(DateTime value) => _date.format(value.toLocal());

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());
}
