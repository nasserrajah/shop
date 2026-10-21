/// Low-level exceptions thrown by data sources.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
