import 'exceptions.dart';
import 'failures.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is ServerException) {
    if (error.statusCode == 404) {
      return NotFoundFailure(error.message, code: '404');
    }
    return ServerFailure(
      error.message,
      code: error.statusCode?.toString() ?? 'server',
    );
  }
  if (error is NetworkException) {
    return NetworkFailure(error.message, code: 'network');
  }
  if (error is ParsingException) {
    return ServerFailure(error.message, code: 'parsing');
  }
  if (error is CacheException) {
    return CacheFailure(error.message, code: 'cache');
  }
  if (error is Failure) {
    return error;
  }
  return const UnknownFailure();
}
