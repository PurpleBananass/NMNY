import 'package:flutter/material.dart';
import 'screens/elder_page.dart';
import 'success_page.dart';
import 'new_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff1c78e5), width: 2.0),
          ),
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Color(0xff1c78e5)),
          floatingLabelStyle: TextStyle(color: Color(0xff1c78e5)),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xff1c78e5),
          selectionColor: Color(0xff1c78e5),
          selectionHandleColor: Color(0xff1c78e5),
        ),
      ),
      home: UserSelectionPage(),
      routes: {
        '/elder': (context) => ElderPage(),
        '/success': (context) => SuccessPage(rrn: ''),
        '/new': (context) => NewPage(),
      },
    );
  }
}

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({Key? key}) : super(key: key);

  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  File? _qrCodeFile;

  @override
  void initState() {
    super.initState();
    _loadQrCode();
  }

  Future<void> _loadQrCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? qrCodePath = prefs.getString('qrCodePath');

    if (qrCodePath != null) {
      setState(() {
        _qrCodeFile = File(qrCodePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var buttonPadding = screenWidth * 0.05;
    var buttonTextSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text('이용자 선택', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_qrCodeFile != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(_qrCodeFile!),
              ),
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
      width: screenWidth * 0.8,
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
