import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib//utils/styles.dart';
import '../lib//widgets/rrn_field.dart';

void main() {
  late FocusNode firstFocusNode;
  late FocusNode secondFocusNode;
  late TextEditingController firstController;
  late TextEditingController secondController;

  setUp(() {
    firstFocusNode = FocusNode();
    secondFocusNode = FocusNode();
    firstController = TextEditingController();
    secondController = TextEditingController();
  });

  tearDown(() {
    firstFocusNode.dispose();
    secondFocusNode.dispose();
    firstController.dispose();
    secondController.dispose();
  });

  Future<void> pumpRrnField(WidgetTester tester, Function onChanged, Function(String) onFirstFieldCompleted) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RrnField(
            firstFocusNode: firstFocusNode,
            secondFocusNode: secondFocusNode,
            firstController: firstController,
            secondController: secondController,
            onChanged: onChanged,
            onFirstFieldCompleted: onFirstFieldCompleted,
          ),
        ),
      ),
    );
  }

  testWidgets('displays the initial UI elements correctly', (WidgetTester tester) async {
    await pumpRrnField(tester, () {}, (String value) {});

    expect(find.text('주민등록번호 앞자리'), findsOneWidget);
    expect(find.text('주민등록번호 뒷자리'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('limits input to 6 digits in the first field', (WidgetTester tester) async {
    await pumpRrnField(tester, () {}, (String value) {});

    await tester.enterText(find.byType(TextField).first, '1234567');
    await tester.pump();

    expect(firstController.text, '123456');
  });

  testWidgets('limits input to 7 digits in the second field', (WidgetTester tester) async {
    await pumpRrnField(tester, () {}, (String value) {});

    await tester.enterText(find.byType(TextField).last, '12345678');
    await tester.pump();

    expect(secondController.text, '1234567');
  });

  testWidgets('calls onChanged when text changes in either field', (WidgetTester tester) async {
    bool onChangedCalled = false;
    await pumpRrnField(tester, () {
      onChangedCalled = true;
    }, (String value) {});

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    expect(onChangedCalled, isTrue);

    onChangedCalled = false; // Reset for second test

    await tester.enterText(find.byType(TextField).last, '1234567');
    await tester.pump();

    expect(onChangedCalled, isTrue);
  });

  testWidgets('calls onFirstFieldCompleted when first field is completed', (WidgetTester tester) async {
    bool onFirstFieldCompletedCalled = false;
    await pumpRrnField(tester, () {}, (String value) {
      onFirstFieldCompletedCalled = true;
    });

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    expect(onFirstFieldCompletedCalled, isTrue);
  });

  testWidgets('moves focus to second field when first field is completed', (WidgetTester tester) async {
    await pumpRrnField(tester, () {}, (String value) {
      secondFocusNode.requestFocus();
    });

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    expect(secondFocusNode.hasFocus, isTrue);
  });
}
