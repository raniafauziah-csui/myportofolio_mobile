import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

http.Response _jsonResponse(Object body, int statusCode) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: const <String, String>{'content-type': 'application/json'},
);

void main() {
  test('Logout clears the local token when server logout fails', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        return _jsonResponse(<String, String>{'token': 'abc123'}, 200);
      }
      if (request.url.path == '/api/v1/auth/logout/') {
        return http.Response('server error', 500);
      }
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    });
    final authState = AuthState(
      ApiClient(client: client, baseUrl: 'https://test.local'),
    );

    await authState.login('rania', 'password');
    expect(authState.isLoggedIn, isTrue);

    await expectLater(authState.logout(), throwsA(isA<ApiException>()));

    expect(authState.isLoggedIn, isFalse);
  });

  testWidgets('Home login and logout actions update authentication state', (
    WidgetTester tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        expect(request.method, 'POST');
        return _jsonResponse(<String, String>{'token': 'abc123'}, 200);
      }
      if (request.url.path == '/api/v1/auth/logout/') {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Token abc123');
        return http.Response('', 204);
      }
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    });

    await tester.pumpWidget(
      MyApp(
        apiClient: ApiClient(client: client, baseUrl: 'https://test.local'),
      ),
    );

    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'rania');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Logout'), findsOneWidget);

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Logout'), findsNothing);
  });
}
