import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// Thin HTTP wrapper that translates transport/decoding problems into
/// [AppException]s so data sources never leak `http` details.
class ApiClient {
  ApiClient({http.Client? client, this.timeout = ApiConstants.requestTimeout})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          _serverMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      if (response.body.trim().isEmpty) {
        throw const ParsingException('The server returned an empty response.');
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw const NetworkException(
        'The request timed out. Please check your connection and try again.',
      );
    } on http.ClientException {
      throw const NetworkException(
        'Unable to reach the server. Please check your internet connection.',
      );
    } on FormatException {
      throw const ParsingException(
        'The server returned data in an unexpected format.',
      );
    }
  }

  String _serverMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'The request could not be processed.',
      401 => 'You are not authorised to perform this action.',
      403 => 'Access to this resource was denied.',
      404 => 'The requested resource was not found.',
      >= 500 => 'The server is temporarily unavailable. Please try again later.',
      _ => 'Request failed with status code $statusCode.',
    };
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
