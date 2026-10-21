import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 2,
);

final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 0,
);

final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
final DateFormat _timeFormat = DateFormat('h:mm a');

String formatCurrency(double value) => _currencyFormat.format(value);

String formatCompactCurrency(double value) => _compactCurrencyFormat.format(value);

String formatDate(DateTime value) => _dateFormat.format(value);

String formatDateTime(DateTime value) => _dateTimeFormat.format(value);

String formatTime(DateTime value) => _timeFormat.format(value);

String formatShortOrderId(String orderId) {
  if (orderId.length <= 6) return orderId;
  return orderId.substring(orderId.length - 6).toUpperCase();
}
