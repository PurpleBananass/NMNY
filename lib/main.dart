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
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff1c78e5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
          // ), // 활성화된 상태에서의 테두리 색상과 두께
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff1c78e5), width: 2.0),
          ), // 포커스된 상태에서의 테두리 색상과 두께
          hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 스타일
          labelStyle: TextStyle(color: Color(0xff1c78e5)), // 라벨 텍스트 스타일
          floatingLabelStyle: TextStyle(color: Color(0xff1c78e5)), // 라벨이 위로 올라갔을 때의 텍스트 스타일
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xff1c78e5), // 텍스트 커서 색상
          selectionColor: Color(0xff1c78e5), // 텍스트 선택 색상
          selectionHandleColor: Color(0xff1c78e5), // 텍스트 선택 핸들 색상
        ),
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
        title: Text('이용자 선택', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
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
            _buildButton(context, '어르신', Colors.blue, buttonPadding * 2, buttonTextSize * 1.2, large: true, route: '/elder', textColor: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, double padding, double textSize, {bool large = false, String? route, Color textColor = Colors.black}) {
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
          foregroundColor: textColor,
          backgroundColor: color,
          padding: EdgeInsets.all(padding),
          textStyle: TextStyle(fontSize: textSize, fontWeight: large ? FontWeight.bold : FontWeight.normal, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}