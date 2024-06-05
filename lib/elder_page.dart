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
  final TextEditingController _rrnFirstController = TextEditingController();
  final TextEditingController _rrnSecondController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _rrnFirstFocusNode = FocusNode();
  final FocusNode _rrnSecondFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _isChecked1 = false;
  bool _isChecked2 = false;

  bool _isNameEntered = false;
  bool _isRrnEntered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
    _rrnFirstFocusNode.addListener(() { setState(() {}); });
    _rrnSecondFocusNode.addListener(() { setState(() {}); });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _rrnFirstFocusNode.dispose();
    _rrnSecondFocusNode.dispose();
    _phoneFocusNode.dispose();
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

  void _handleRrnInput() {
    if (_rrnFirstController.text.length == 6 && _rrnSecondController.text.length == 7) {
      setState(() {
        _isRrnEntered = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_phoneFocusNode);
      });
    }
  }

  Future<void> _submitData() async {
    if (!_isChecked1 || !_isChecked2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 약관에 동의해야 합니다.')));
      return;
    }

    final rrn = '${_rrnFirstController.text}-${_rrnSecondController.text}';
    final url = Uri.parse('http://10.0.2.2:5000/submit'); // Update with your server address
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'rrn': rrn,
      'auth_method': _selectedAuthOption,
      'agreements': {
        'agreement1': _isChecked1,
        'agreement2': _isChecked2,
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
      appBar: AppBar(
        // 상단바
        title: Text('간편인증 요청을 위해'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 휴대폰 번호
              if (_isRrnEntered) ...[
                TextField(
                  focusNode: _phoneFocusNode,
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '휴대폰 번호',
                    labelStyle: TextStyle(fontSize: 40),
                    hintText: "'-' 없이 입력",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    PhoneNumberFormatter(),
                  ],
                  style: TextStyle(fontSize: 60),
                  textAlign: _rrnFirstFocusNode.hasFocus ? TextAlign.left : TextAlign.center,
                ),
              ],
              SizedBox(height: 10),

              // 주민등록번호
              if (_isNameEntered) ...[
                TextField (
                  focusNode: _rrnFirstFocusNode,
                  controller: _rrnFirstController,
                  decoration: InputDecoration(
                    labelText: '주민등록번호 앞자리',
                    labelStyle: TextStyle(fontSize: 40),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (_) => _handleRrnInput(),
                  style: TextStyle(fontSize: 80),
                  textAlign: _rrnFirstFocusNode.hasFocus ? TextAlign.left : TextAlign.center,
                ),
                Center(child: Text('-', style: TextStyle(fontSize: 60))),
                TextField (
                  focusNode: _rrnSecondFocusNode,
                  controller: _rrnSecondController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    labelText: '주민등록번호 뒷자리',
                    labelStyle: TextStyle(fontSize: 40),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: (_) => _handleRrnInput(),
                  style: TextStyle(fontSize: 80),
                  textAlign: _rrnSecondFocusNode.hasFocus ? TextAlign.left : TextAlign.center,
                ),
              ],

              // 이름
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

              // 이름 입력 완료 버튼
              ElevatedButton(
                onPressed: _handleNameSubmit,
                child: Text('이름 입력 완료'),
              ),

              // 약관 동의
              // ElevatedButton(
              //   onPressed: _submitData,
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 20),
              //     textStyle: TextStyle(fontSize: 18),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Text('다음'),
              //       SizedBox(width: 10),
              //       Icon(Icons.arrow_forward),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 20),
              // Text(
              //   '약관에 모두 동의',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              // CheckboxListTile(
              //   value: _isChecked1,
              //   onChanged: (bool? value) {
              //     setState(() {
              //       _isChecked1 = value ?? false;
              //     });
              //   },
              //   title: Text('[필수] 개인정보 이용 동의 (국세청)'),
              // ),
              // CheckboxListTile(
              //   value: _isChecked2,
              //   onChanged: (bool? value) {
              //     setState(() {
              //       _isChecked2 = value ?? false;
              //     });
              //   },
              //   title: Text('[필수] 제3자 정보제공 동의 (국세청)'),
              // ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If the text is being deleted, simply return the new value
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Format the new text value with hyphens
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 6) buffer.write('-');
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}