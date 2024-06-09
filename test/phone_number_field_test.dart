import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib//utils/styles.dart';
import '../lib//widgets/phone_number_field.dart';

void main() {
  late FocusNode focusNode;
  late TextEditingController controller;

  setUp(() {
    focusNode = FocusNode();
    controller = TextEditingController();
  });

  tearDown(() {
    focusNode.dispose();
    controller.dispose();
  });

  Future<void> pumpPhoneNumberField(WidgetTester tester, Function onChanged) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhoneNumberField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('displays the initial UI elements correctly', (WidgetTester tester) async {
    await pumpPhoneNumberField(tester, () {});

    expect(find.text('휴대폰 번호'), findsOneWidget);
    expect(find.text("'-' 없이 입력"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('formats the phone number correctly', (WidgetTester tester) async {
    await pumpPhoneNumberField(tester, () {});

    await tester.enterText(find.byType(TextField), '01012345678');
    await tester.pump();

    expect(controller.text, '010-1234-5678');
  });

  testWidgets('limits input to 11 digits', (WidgetTester tester) async {
    await pumpPhoneNumberField(tester, () {});

    await tester.enterText(find.byType(TextField), '010123456789');
    await tester.pump();

    expect(controller.text, '010-1234-5678'); // Only the first 11 digits should be formatted
  });

  testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
    bool onChangedCalled = false;
    await pumpPhoneNumberField(tester, () {
      onChangedCalled = true;
    });

    await tester.enterText(find.byType(TextField), '01012345678');
    await tester.pump();

    expect(onChangedCalled, isTrue);
  });
}
