import '../error/exceptions.dart';
import '../error/failures.dart';

/// Turns any thrown object into a short, user-facing message.
String readableErrorMessage(
  Object? error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is Failure) return error.message;
  if (error is AppException) return error.message;
  if (error == null) return fallback;

  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    final message = text.substring('Exception: '.length).trim();
    if (message.isNotEmpty) return message;
  }
  return fallback;
}
