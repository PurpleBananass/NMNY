import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'success_page.dart';
import 'new_page.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SuccessPage', () {
    testWidgets('shows success dialog on successful authentication', (WidgetTester tester) async {
      final client = MockClient();

      // Mock HTTP response
      when(client.post(
        Uri.parse('http://10.0.2.2:5000/complete'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: SuccessPage(rrn: '123456-1234567'),
        ),
      );

      await tester.tap(find.text('인증 완료'));
      await tester.pumpAndSettle();

      verify(client.post(
        Uri.parse('http://10.0.2.2:5000/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rrn': '123456-1234567'}),
      )).called(1);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('rrn'), '123456-1234567');
      expect(find.byType(NewPage), findsOneWidget);
    });

    testWidgets('shows failure dialog on failed authentication', (WidgetTester tester) async {
      final client = MockClient();

      // Mock HTTP response
      when(client.post(
        Uri.parse('http://10.0.2.2:5000/complete'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      await tester.pumpWidget(
        MaterialApp(
          home: SuccessPage(rrn: '123456-1234567'),
        ),
      );

      await tester.tap(find.text('인증 완료'));
      await tester.pumpAndSettle();

      expect(find.text('인증 실패'), findsOneWidget);
      expect(find.text('인증 확인 후 완료해주세요'), findsOneWidget);
    });

    testWidgets('shows error dialog on request error', (WidgetTester tester) async {
      final client = MockClient();

      // Mock HTTP response
      when(client.post(
        Uri.parse('http://10.0.2.2:5000/complete'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: SuccessPage(rrn: '123456-1234567'),
        ),
      );

      await tester.tap(find.text('인증 완료'));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsOneWidget);
      expect(find.text('인증 확인 후 완료해주세요'), findsOneWidget);
    });
  });
}
