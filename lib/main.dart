import 'package:flutter/material.dart';
import 'elder_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('이용자 선택'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(context, '일반', Colors.yellow),
                SizedBox(width: 10),
                _buildButton(context, '의료진', Colors.green),
              ],
            ),
            SizedBox(height: 10),
            _buildButton(context, '어르신', Colors.blue, large: true, route: '/elder'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, {bool large = false, String? route}) {
    return ElevatedButton(
      onPressed: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: large ? EdgeInsets.all(40) : EdgeInsets.all(20),
        textStyle: large
            ? TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            : TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(text),
    );
  }
}
