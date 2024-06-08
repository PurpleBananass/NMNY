import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_page.dart';
class SuccessPage extends StatelessWidget {
  final String rrn;
  // final String birthDate;

  const SuccessPage({Key? key, required this.rrn}) : super(key: key);

  Future<void> _completeAuthentication(BuildContext context) async {
    final url = Uri.parse('http://34.64.55.10:8080/complete'); // Update with your server address
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'rrn': rrn,
      // 'birth_date': birthDate,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Save RRN to local cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('rrn', rrn);

        // Navigate to the new page if the response is successful
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewPage()));
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
        title: Text('간편서명'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'KB모바일인증을 진행해주세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '입력하신 휴대폰으로 인증 요청 메시지를 보냈습니다.\nKB스타뱅킹앱에서 인증을 진행해주세요.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Icon(Icons.message, size: 50),
                    SizedBox(height: 10),
                    Text('STEP 01\nKB스타뱅킹앱에서\n메시지 확인', textAlign: TextAlign.center),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 30),
                Column(
                  children: <Widget>[
                    Icon(Icons.verified_user, size: 50),
                    SizedBox(height: 10),
                    Text('STEP 02\nKB모바일인증서\n인증진행', textAlign: TextAlign.center),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 30),
                Column(
                  children: <Widget>[
                    Icon(Icons.check_circle, size: 50),
                    SizedBox(height: 10),
                    Text('STEP 03\n인증 완료 후,\n현재 화면의 인증 완료 클릭', textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _completeAuthentication(context),
              child: Text('인증 완료'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
