import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElderPage extends StatefulWidget {
  const ElderPage({Key? key}) : super(key: key);

  @override
  _ElderPageState createState() => _ElderPageState();
}

class _ElderPageState extends State<ElderPage> {
  String? _selectedAuthOption;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isChecked5 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('간편인증 요청을 위해'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '아래 정보를 입력해주세요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '김찐삼',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '휴대폰 번호',
                  hintText: '010-1234-5678',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: '생년월일',
                  hintText: 'yyyy/MM/dd',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[\d/]'), allow: true),
                  LengthLimitingTextInputFormatter(10),
                  BirthDateInputFormatter(),
                ],
              ),
              SizedBox(height: 10),
              Text(
                '본인인증 수단',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: <Widget>[
                  _buildAuthOption('카카오톡 인증', 'assets/kakao_icon.png'),
                  _buildAuthOption('PAYCO 인증', 'assets/pass_icon.png'),
                  _buildAuthOption('국민은행모바일 인증', 'assets/pass_icon.png'),
                  _buildAuthOption('삼성패스 인증', 'assets/pass_icon.png'),
                  _buildAuthOption('통신사 PASS 인증', 'assets/pass_icon.png'),
                  _buildAuthOption('신한 인증', 'assets/pass_icon.png'),
                  _buildAuthOption('NAVER 인증', 'assets/pass_icon.png')
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the button press
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('다음'),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                '약관에 모두 동의',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                value: _isChecked1,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked1 = value ?? false;
                  });
                },
                title: Text('[필수] 개인정보 이용 동의'),
              ),
              CheckboxListTile(
                value: _isChecked2,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked2 = value ?? false;
                  });
                },
                title: Text('[필수] 제3자 정보제공 동의'),
              ),
              CheckboxListTile(
                value: _isChecked3,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked3 = value ?? false;
                  });
                },
                title: Text('[필수] 개인정보 제3자 정보제공 동의'),
              ),
              CheckboxListTile(
                value: _isChecked4,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked4 = value ?? false;
                  });
                },
                title: Text('[필수] 고유식별정보 수집 및 이용 동의'),
              ),
              CheckboxListTile(
                value: _isChecked5,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked5 = value ?? false;
                  });
                },
                title: Text('[필수] 개인정보 수집 및 이용 동의'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOption(String label, String iconPath) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAuthOption = label;
          });
        },
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(iconPath, width: 50, height: 50),
                if (_selectedAuthOption == label)
                  Icon(Icons.check_circle, color: Colors.blue, size: 50),
              ],
            ),
            SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;

    String formattedText = newValue.text;

    if (newTextLength == 4 || newTextLength == 7) {
      formattedText += '/';
      selectionIndex++;
    } else if (newTextLength > 10) {
      formattedText = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
