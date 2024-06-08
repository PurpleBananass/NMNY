import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dio/dio.dart';
import 'package:nmny/medication_info_page.dart';

void main() {
  group('MedicationInfoPage', () {
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
    });

    testWidgets('displays medication info correctly', (WidgetTester tester) async {
      dioAdapter.onGet(
        'http://10.0.2.2:5000/medications',
        (request) => request.reply(200, {
          "ResultList": [
            {
              "No": "sample string 1",
              "DateOfPreparation": "2024-05-26",
              "Dispensary": "sample dispensary",
              "PhoneNumber": "010-1234-5678",
              "DrugList": [
                {
                  "No": "drug string 1",
                  "Effect": "sample effect",
                  "Code": "sample code",
                  "Name": "sample name",
                  "Component": "sample component",
                  "Quantity": "sample quantity",
                  "DosagePerOnce": "sample dosage",
                  "DailyDose": "sample daily dose",
                  "TotalDosingDays": "sample total days"
                }
              ]
            }
          ]
        }),
      );

      await tester.pumpWidget(MaterialApp(home: MedicationInfoPage()));
      await tester.pumpAndSettle();

      expect(find.text('의약품명: sample name'), findsOneWidget);
      expect(find.text('효능: sample effect'), findsOneWidget);
    });
  });
}
