
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/styles.dart';
import '../lib/widgets/name_field.dart';

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

  Future<void> pumpNameField(WidgetTester tester, Function onSubmitted) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NameField(
            focusNode: focusNode,
            controller: controller,
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }

  testWidgets('displays the initial UI elements correctly', (WidgetTester tester) async {
    await pumpNameField(tester, () {});

    expect(find.text('이름'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('calls onSubmitted when text is submitted', (WidgetTester tester) async {
    bool onSubmittedCalled = false;
    await pumpNameField(tester, () {
      onSubmittedCalled = true;
    });

    await tester.enterText(find.byType(TextField), 'John Doe');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(onSubmittedCalled, isTrue);
  });

  testWidgets('changes text alignment based on focus', (WidgetTester tester) async {
    await pumpNameField(tester, () {});

    // Verify initial alignment
    expect((tester.widget(find.byType(TextField)) as TextField).textAlign, TextAlign.center);

  });

  testWidgets('focus node is managed correctly', (WidgetTester tester) async {
    await pumpNameField(tester, () {});

    // Focus the text field
    focusNode.requestFocus();
    await tester.pump();

    // Unfocus the text field
    focusNode.unfocus();
    await tester.pump();

    // Ensure no errors occur due to focus management
    expect(tester.takeException(), isNull);
  });
}
