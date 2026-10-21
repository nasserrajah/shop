import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/core/result/result.dart';

void main() {
  group('Result', () {
    test('success exposes data and isSuccess', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure exposes failure and isFailure', () {
      const failure = ServerFailure('Server exploded');
      const result = Result<int>.failure(failure);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold runs the matching branch', () {
      const success = Result<int>.success(5);
      const failure = Result<int>.failure(CacheFailure('Nope'));

      expect(
        success.fold(onSuccess: (data) => data * 2, onFailure: (_) => -1),
        10,
      );
      expect(
        failure.fold(
          onSuccess: (_) => 'ok',
          onFailure: (error) => error.message,
        ),
        'Nope',
      );
    });

    test('map transforms success and preserves failure', () {
      const success = Result<int>.success(5);
      const failure = Result<int>.failure(ServerFailure('Bad'));

      final mappedSuccess = success.map((data) => 'value: $data');
      final mappedFailure = failure.map((data) => 'value: $data');

      expect(mappedSuccess.dataOrNull, 'value: 5');
      expect(mappedFailure.isFailure, isTrue);
      expect(mappedFailure.failureOrNull?.message, 'Bad');
    });
  });
}
