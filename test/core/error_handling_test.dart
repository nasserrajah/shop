import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/error/exceptions.dart';
import 'package:shop/core/error/failure_mapper.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/core/utils/error_message.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('maps a 404 server exception to NotFoundFailure', () {
      final failure = mapExceptionToFailure(
        const ServerException('Missing', statusCode: 404),
      );

      expect(failure, isA<NotFoundFailure>());
      expect(failure.code, '404');
    });

    test('maps other server exceptions to ServerFailure with status code', () {
      final failure = mapExceptionToFailure(
        const ServerException('Boom', statusCode: 500),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Boom');
      expect(failure.code, '500');
    });

    test('maps network, parsing and cache exceptions', () {
      expect(
        mapExceptionToFailure(const NetworkException('Offline')),
        isA<NetworkFailure>(),
      );
      expect(
        mapExceptionToFailure(const ParsingException('Bad body')),
        isA<ServerFailure>(),
      );
      expect(
        mapExceptionToFailure(const CacheException('Bad cache')),
        isA<CacheFailure>(),
      );
    });

    test('passes failures through unchanged', () {
      const original = ValidationFailure('Invalid');
      expect(mapExceptionToFailure(original), same(original));
    });

    test('maps unknown errors to UnknownFailure', () {
      expect(mapExceptionToFailure(Exception('???')), isA<UnknownFailure>());
    });
  });

  group('readableErrorMessage', () {
    test('prefers failure and app exception messages', () {
      expect(readableErrorMessage(const ServerFailure('Save failed')), 'Save failed');
      expect(readableErrorMessage(const AppException('No network')), 'No network');
    });

    test('strips the Exception: prefix and falls back when unknown', () {
      expect(readableErrorMessage(Exception('Something specific')), 'Something specific');
      expect(readableErrorMessage(Object()), 'Something went wrong. Please try again.');
      expect(readableErrorMessage(null, fallback: 'Custom'), 'Custom');
    });
  });
}
