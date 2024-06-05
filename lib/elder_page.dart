import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'success_page.dart';

class ElderPage extends StatefulWidget {
  const ElderPage({Key? key}) : super(key: key);

  @override
  _ElderPageState createState() => _ElderPageState();
}

class _ElderPageState extends State<ElderPage> {
  String? _selectedAuthOption;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _rrnFirstController = TextEditingController();
  final TextEditingController _rrnSecondController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _rrnFirstFocusNode = FocusNode();

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isChecked5 = false;

  bool _isNameEntered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _rrnFirstFocusNode.dispose();
    super.dispose();
  }

  void _handleNameSubmit() {
    setState(() {
      _isNameEntered = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_rrnFirstFocusNode);
    });
  }

  Future<void> _submitData() async {
    if (!_isChecked1 || !_isChecked2 || !_isChecked3 || !_isChecked4 || !_isChecked5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 약관에 동의해야 합니다.')));
      return;
    }

    final rrn = '${_rrnFirstController.text}-${_rrnSecondController.text}';
    final url = Uri.parse('http://10.0.2.2:5000/submit'); // Update with your server address
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'birth_date': _birthDateController.text,
      'rrn': rrn,
      'auth_method': _selectedAuthOption,
      'agreements': {
        'agreement1': _isChecked1,
        'agreement2': _isChecked2,
        'agreement3': _isChecked3,
        'agreement4': _isChecked4,
        'agreement5': _isChecked5,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data submitted successfully')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage(rrn: rrn)),
        );
      } else {
        print('Failed to submit data');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit data')));
      }
    } catch (error) {
      print('Error submitting data: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting data: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 상단바
        title: Text('간편인증 요청을 위해'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_isNameEntered) ...[ // 이름 입력 완료 시
                Row( // 주민등록번호 입력
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _rrnFirstFocusNode,
                        controller: _rrnFirstController,
                        decoration: InputDecoration(
                          labelText: '주민등록번호 앞자리',
                          hintText: '123456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('-'),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _rrnSecondController,
                        decoration: InputDecoration(
                          labelText: '주민등록번호 뒷자리',
                          hintText: '1234567',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  // 휴대폰 번호 입력`
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
                  // 생년월일 입력
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
                    _buildAuthOption('PASS 인증', 'assets/pass_icon.png'),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitData,
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
                  title: Text('[필수] 개인정보 이용 동의 (국세청)'),
                ),
                CheckboxListTile(
                  value: _isChecked2,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked2 = value ?? false;
                    });
                  },
                  title: Text('[필수] 제3자 정보제공 동의 (국세청)'),
                ),
                CheckboxListTile(
                  value: _isChecked3,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked3 = value ?? false;
                    });
                  },
                  title: Text('[필수] 개인정보 제3자 정보제공 동의 (삼팔삼)'),
                ),
                CheckboxListTile(
                  value: _isChecked4,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked4 = value ?? false;
                    });
                  },
                  title: Text('[필수] 고유식별정보 수집 및 이용 동의 (삼팔삼)'),
                ),
                CheckboxListTile(
                  value: _isChecked5,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked5 = value ?? false;
                    });
                  },
                  title: Text('[필수] 개인정보 수집 및 이용 동의 (삼팔삼)'),
                ),
              ],
              // 이름 입력 필드
              TextField(
                focusNode: _nameFocusNode,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '김찐삼',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => _handleNameSubmit(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleNameSubmit,
                // style: ElevatedButton.styleFrom(
                //   padding: EdgeInsets.symmetric(vertical: 20),
                //   textStyle: TextStyle(fontSize: 18),
                // ),
                child: Text('이름 입력 완료'),
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
