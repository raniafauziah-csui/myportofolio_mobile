import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/screens/skill_detail_screen.dart';
import 'package:myportofolio_mobile/screens/skill_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const String _baseUrl = 'https://api.example.com';

Map<String, dynamic> _skillJson() => <String, dynamic>{
  'id': '5b4722b3-2b4e-4e8c-9aef-b0ff4d3e3210',
  'name': 'Flutter',
  'category': 'programming',
  'description': 'Mobile app development',
  'icon_url': null,
  'star_count': 3,
  'is_starred': false,
};

Widget _buildApp(ApiClient api) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider<AuthState>(create: (_) => AuthState(api)),
    ],
    child: const MaterialApp(home: SkillListScreen()),
  );
}

Finder _richTextContaining(String text) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is RichText && widget.text.toPlainText().contains(text),
  );
}

void main() {
  testWidgets('Empty skill list still supports pull to refresh', (
    WidgetTester tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode(<dynamic>[]),
        200,
        headers: const <String, String>{'content-type': 'application/json'},
      ),
    );

    await tester.pumpWidget(
      _buildApp(ApiClient(client: client, baseUrl: _baseUrl)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No skills found.'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Skill card opens the detail screen', (
    WidgetTester tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode(<dynamic>[_skillJson()]),
        200,
        headers: const <String, String>{'content-type': 'application/json'},
      ),
    );

    await tester.pumpWidget(
      _buildApp(ApiClient(client: client, baseUrl: _baseUrl)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('programming\nMobile app development'), findsOneWidget);

    await tester.tap(find.text('Flutter'));
    await tester.pumpAndSettle();

    expect(find.byType(SkillDetailScreen), findsOneWidget);
    expect(_richTextContaining('Star count: 3'), findsOneWidget);
    expect(_richTextContaining('Starred: No'), findsOneWidget);
  });

  testWidgets('Adding a skill requires login and sends the auth token', (
    WidgetTester tester,
  ) async {
    bool created = false;
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/skills/' && request.method == 'GET') {
        return http.Response(
          jsonEncode(created ? <dynamic>[_skillJson()] : <dynamic>[]),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/v1/auth/token/') {
        return http.Response(
          jsonEncode(<String, String>{'token': 'abc123'}),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/v1/skills/' && request.method == 'POST') {
        expect(request.headers['Authorization'], 'Token abc123');
        expect(jsonDecode(request.body), <String, dynamic>{
          'name': 'Flutter',
          'category': 'programming',
          'description': 'Build mobile apps',
          'icon_url': null,
        });
        created = true;
        return http.Response(
          jsonEncode(_skillJson()),
          201,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    });
    final api = ApiClient(client: client, baseUrl: _baseUrl);

    await tester.pumpWidget(_buildApp(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add skill'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsWidgets);

    final usernameField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);
    await tester.enterText(usernameField, 'rania');
    await tester.enterText(passwordField, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Skill'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Flutter');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Build mobile apps',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Skill berhasil ditambahkan.'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });
}
