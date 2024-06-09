import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nm/utils/styles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'medication_info_page.dart';

class SuccessPage extends StatelessWidget {
  final String rrn;
  const SuccessPage({super.key, required this.rrn});

  Future<void> _completeAuthentication(BuildContext context) async {
    final url = Uri.parse('http://34.64.55.10:8080/complete'); // Update with your server address
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'rrn': rrn,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Save RRN to local cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('rrn', rrn);

        // Navigate to the new page if the response is successful
        Navigator.push(context, MaterialPageRoute(builder: (context) => MedicationInfoPage()));
      } else {
        // Show a pop-up message if the response fails
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('인증 실패'),
            content: Text('인증 확인 후 완료해주세요'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error completing authentication: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('인증 확인 후 완료해주세요'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '간편 서명',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              '카카오톡 인증을 진행해 주세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '입력하신 휴대폰으로 인증 요청 메시지를 보냈습니다.\n카카오톡에서 인증을 진행해주세요.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: <Widget>[
                      Text('STEP 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      Image.asset('assets/kakaotalk.png', width: 50),
                      SizedBox(height: 10),
                      Text('카카오톡\n확인', textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 30),
                Flexible(
                  child: Column(
                    children: const <Widget>[
                      Text('STEP 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      Icon(Icons.verified_user, size: 50),
                      SizedBox(height: 10),
                      Text('카카오\n인증 진행', textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 30),
                Flexible(
                  child: Column(
                    children: const <Widget>[
                      Text('STEP 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      Icon(Icons.check_circle, size: 50),
                      SizedBox(height: 10),
                      Text('인증 완료 클릭', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _completeAuthentication(context),
              style: ElevatedButton.styleFrom(
                padding: inputPadding,
                textStyle: buttonTextStyle,
              ),
              child: Text('인증 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
