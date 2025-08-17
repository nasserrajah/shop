import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client client;
  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> get(String path) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final res = await client.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed GET ${uri.toString()} status: ${res.statusCode}');
    }
  }
}