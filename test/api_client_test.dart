import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/skill.dart';

const String _baseUrl = 'https://api.example.com';

Map<String, dynamic> _skillJson({
  String id = '5b4722b3-2b4e-4e8c-9aef-b0ff4d3e3210',
  String name = 'Flutter',
  String category = 'programming',
  String description = 'Mobile app development',
  String? iconUrl,
  int starCount = 3,
  bool isStarred = false,
}) => <String, dynamic>{
  'id': id,
  'name': name,
  'category': category,
  'description': description,
  'icon_url': iconUrl,
  'star_count': starCount,
  'is_starred': isStarred,
};

Skill _skill() => Skill.fromJson(_skillJson());

http.Response _jsonResponse(Object body, int statusCode) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: const <String, String>{'content-type': 'application/json'},
);

void main() {
  test('getSkills fetches and parses the skill list', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/skills/');
      expect(request.headers['Accept'], 'application/json');
      return _jsonResponse(<dynamic>[_skillJson()], 200);
    });

    final api = ApiClient(client: client, baseUrl: _baseUrl);
    final skills = await api.getSkills();

    expect(skills, hasLength(1));
    expect(skills.single.name, 'Flutter');
    expect(skills.single.category, 'programming');
    expect(skills.single.starCount, 3);
  });

  test(
    'createSkill posts JSON with the token and returns the created skill',
    () async {
      final skill = _skill();
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/skills/');
        expect(request.headers['Accept'], 'application/json');
        expect(
          request.headers['Content-Type'],
          'application/json; charset=UTF-8',
        );
        expect(request.headers['Authorization'], 'Token abc123');
        expect(jsonDecode(request.body), skill.toJson());
        return _jsonResponse(
          _skillJson(id: 'server-generated-id', isStarred: true),
          201,
        );
      });

      final api = ApiClient(client: client, baseUrl: _baseUrl);
      final created = await api.createSkill(skill, token: 'abc123');

      expect(created.id, 'server-generated-id');
      expect(created.isStarred, isTrue);
    },
  );

  test('obtainToken posts credentials and returns the token', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/token/');
      expect(
        request.headers['Content-Type'],
        'application/json; charset=UTF-8',
      );
      expect(jsonDecode(request.body), <String, String>{
        'username': 'rania',
        'password': 'secret',
      });
      return _jsonResponse(<String, String>{'token': 'abc123'}, 200);
    });

    final api = ApiClient(client: client, baseUrl: _baseUrl);

    expect(await api.obtainToken('rania', 'secret'), 'abc123');
  });

  test('logout posts the token and accepts an empty 204 response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.headers['Authorization'], 'Token abc123');
      return http.Response('', 204);
    });

    final api = ApiClient(client: client, baseUrl: _baseUrl);

    await api.logout(token: 'abc123');
  });

  test('non-2xx responses throw ApiException', () async {
    final client = MockClient((_) async => http.Response('bad request', 400));
    final api = ApiClient(client: client, baseUrl: _baseUrl);

    expect(
      api.getSkills(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', 'bad request'),
      ),
    );
  });
}
