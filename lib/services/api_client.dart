import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/skill.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  static const String _skillsPath = '/api/v1/skills/';
  static const String _tokenPath = '/api/v1/auth/token/';
  static const String _logoutPath = '/api/v1/auth/logout/';

  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({String? token}) => <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<Skill>> getSkills() async {
    final response = await _client.get(
      _uri(_skillsPath),
      headers: const <String, String>{'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Skill.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Skill> createSkill(Skill skill, {required String token}) async {
    final response = await _client.post(
      _uri(_skillsPath),
      headers: _headers(token: token),
      body: jsonEncode(skill.toJson()),
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(decoded);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri(_tokenPath),
      headers: _headers(),
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri(_logoutPath),
      headers: _headers(token: token),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
