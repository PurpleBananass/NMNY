import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:logging/logging.dart';
import 'medication_detail_page.dart';

class MedicationInfoPage extends StatefulWidget {
  const MedicationInfoPage({super.key});

  @override
  MedicationInfoPageState createState() => MedicationInfoPageState();
}

class MedicationInfoPageState extends State<MedicationInfoPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _medications = [];
  String? _qrCodeUrl;
  File? _qrCodeFile;

  Logger logger = Logger('MedicationInfoPage');

  // final _encryptionKey = encrypt.Key.fromUtf8('1joonwooseunghonaegamuckneunyak1'); // 32 chars key
  // final _iv = encrypt.IV.fromLength(16);

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
      logger.info('Response status: ${response.statusCode}');
      logger.info('Response body: ${utf8.decode(response.bodyBytes)}');
      _qrCodeUrl = 'http://34.64.55.10:8080/medications/pdf?rrn=${_encryptRrn(rrn)}';
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
      logger.info('Error fetching data: $error');
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

        // QR 코드 생성 완료 후 모달 표시
        _showQrCodeModal();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('qrCodePath', filePath);
      }
    }
  }

  void _showQrCodeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('QR코드가 생성되었습니다.'),
              SizedBox(height: 16),
              if (_qrCodeFile != null)
                Image.file(_qrCodeFile!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Set<String> displayedNumbers = {}; // 중복된 일련번호 추적하기 위한 집합

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    String number = medication['No'];

    if (displayedNumbers.contains(number)) {
      return SizedBox.shrink(); // 이미 표시된 일련번호는 생략
    } else {
      displayedNumbers.add(number);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicationDetailPage(medication: medication)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '${medication['DateOfPreparation']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Text('처방: ${medication['Dispensary']}'),
              Text('의약품명: ${medication['DrugList'][0]['Name']}'),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    displayedNumbers.clear(); // 화면을 다시 그릴 때마다 중복된 일련번호 추적을 초기화

    return Scaffold(
      appBar: AppBar(
        title: Text('내가 복용중인 약'),
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
              ],
            ),
    );
  }
}