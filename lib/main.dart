import 'package:flutter/material.dart';
import 'screens/elder_page.dart';
import 'success_page.dart';
import 'new_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserSelectionPage(),
      routes: {
        '/elder': (context) => ElderPage(),
        '/success': (context) => SuccessPage(rrn: ''), // Placeholder for navigation with rrn
        '/new': (context) => NewPage(),
      },
    );
  }
}

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var buttonPadding = screenWidth * 0.05; // 화면 너비의 5% 만큼 패딩 설정
    var buttonTextSize = screenWidth * 0.1; // 화면 너비의 5% 만큼 텍스트 크기 설정

    return Scaffold(
      appBar: AppBar(
        title: Text('이용자 선택'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
                
            //   ],
            // ),
            _buildButton(context, '일반', Colors.yellow, buttonPadding, buttonTextSize),
            SizedBox(height: 10),
            _buildButton(context, '의료진', Colors.green, buttonPadding, buttonTextSize),
            SizedBox(height: 10),
            _buildButton(context, '어르신', Colors.blue, buttonPadding * 2, buttonTextSize * 1.2, large: true, route: '/elder'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, double padding, double textSize, {bool large = false, String? route}) {
    var screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.8, // 버튼 너비 고정
      child: ElevatedButton(
        onPressed: () {
          if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.all(padding),
          textStyle: TextStyle(fontSize: textSize, fontWeight: large ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}