import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:encrypt/encrypt.dart' as encrypt;

class MedicationInfoPage extends StatefulWidget {
  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _medications = [];
  String? _qrCodeUrl;
  File? _qrCodeFile;

  final _encryptionKey = encrypt.Key.fromUtf8('1joonwooseunghonaegamuckneunyak1'); // 32 chars key
  final _iv = encrypt.IV.fromLength(16);

  @override
  void initState() {
    super.initState();
    _fetchMedicationInfo();
  }

  Future<void> _fetchMedicationInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rrn = prefs.getString('rrn');

    if (rrn == null) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://34.64.55.10:8080/medication');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'rrn': rrn});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');
      // print('ENCODED: ${_qrCodeUrl}');
      _qrCodeUrl = 'http://34.64.55.10:8080/medications/pdf?rrn=${_encryptRrn(rrn)}';
      // print('ENCODED: ${_qrCodeUrl}');
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _medications = data['ResultList'];
          _qrCodeUrl = 'http://34.64.55.10:8080/medications/pdf?rrn=${_encryptRrn(rrn)}';
          _isLoading = false;
          _generateQrCode();
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _encryptRrn(String rrn) {
    // final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    // final encrypted = encrypter.encrypt(rrn, iv: _iv);
    // return encrypted.base64;
    final key = encrypt.Key.fromUtf8('4f1aaae66406e358');
  final iv = encrypt.IV.fromUtf8('df1e180949793972');
  String encryptedText;
  // String plainText = 'Chanaka';
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(rrn, iv: iv);
  encryptedText = encrypted.base64;
  return encryptedText;
  }

  Future<void> _generateQrCode() async {
    if (_qrCodeUrl != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/qrcode.png';

      final qrValidationResult = QrValidator.validate(
        data: _qrCodeUrl!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        final image = await painter.toImage(200);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        await File(filePath).writeAsBytes(bytes);
        setState(() {
          _qrCodeFile = File(filePath);
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('qrCodePath', filePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약 상세정보'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Error fetching data'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _medications.length,
                        itemBuilder: (context, index) {
                          return _buildMedicationCard(_medications[index]);
                        },
                      ),
                    ),
                    if (_qrCodeFile != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.file(_qrCodeFile!),
                      ),
                  ],
                ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '의약품명: ${medication['DrugList'][0]['Name']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('영문 의약품명: ${medication['DrugList'][0]['Name']}'),
            Text('제조회사: ${medication['Dispensary']}'),
            Text('전화번호: ${medication['PhoneNumber']}'),
            Text('준비일자: ${medication['DateOfPreparation']}'),
            Text('번호: ${medication['No']}'),
            SizedBox(height: 16),
            ...medication['DrugList'].map<Widget>((drug) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('효능: ${drug['Effect']}'),
                    Text('성분: ${drug['Component']}'),
                    Text('수량: ${drug['Quantity']}'),
                    Text('1회 복용량: ${drug['DosagePerOnce']}'),
                    Text('일일 복용량: ${drug['DailyDose']}'),
                    Text('총 복용일수: ${drug['TotalDosingDays']}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
