import 'package:flutter/material.dart';
import '../../widgets/phone_number_field.dart';
import '../../widgets/rrn_field.dart';
import '../../widgets/name_field.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import '../../utils/styles.dart';
import '../success_page.dart';

class ElderPage extends StatefulWidget {
  const ElderPage({super.key});

  @override
  _ElderPageState createState() => _ElderPageState();
}

class _ElderPageState extends State<ElderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rrnFirstController = TextEditingController();
  final TextEditingController _rrnSecondController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _rrnFirstFocusNode = FocusNode();
  final FocusNode _rrnSecondFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _isNameEntered = false;
  bool _isRrnEntered = false;
  bool _isPhoneEntered = false;

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  
  @override
  void initState() {
    super.initState();
    _requestNameFocus();
    _addRrnFocusListeners();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _rrnFirstFocusNode.dispose();
    _rrnSecondFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _requestNameFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
  }

  void _addRrnFocusListeners() {
    _rrnFirstFocusNode.addListener(() {
      setState(() {});
    });
    _rrnSecondFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _handleNameSubmit() {
    setState(() {
      _isNameEntered = true;
    });
    _requestRrnFirstFocus();
  }

  void _requestRrnFirstFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_rrnFirstFocusNode);
    });
  }

  void _handleRrnFirstFieldCompleted(String value) {
    FocusScope.of(context).requestFocus(_rrnSecondFocusNode);
  }

  void _handleRrnInput() {
    if (_rrnFirstController.text.length == 6 && _rrnSecondController.text.length == 7) {
      setState(() {
        _isRrnEntered = true;
      });
      _requestPhoneFocus();
    }
  }

  void _requestPhoneFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_phoneFocusNode);
    });
  }

  void _handlePhoneInput() {
    if (_phoneController.text.length == 13) {
      setState(() {
        _isPhoneEntered = true;
      });
      _showAgreementModal();
    }
  }

  void _showAgreementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container( 
              height: MediaQuery.of(context).size.height * 0.3, 
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '서비스 약관 동의',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('개인정보이용 동의'),
                            value: _isChecked1,
                            onChanged: (value) {
                              setState(() {
                                _isChecked1 = value ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('고유식별정보처리 동의'),
                            value: _isChecked2,
                            onChanged: (value) {
                              setState(() {
                                _isChecked2 = value ?? false;
                              });
                            },
                          ),
                          // ... (다른 약관 추가) ...
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                      onPressed: () {
                        setState(() {
                          _isChecked1 = true;
                          _isChecked2 = true;
                          // ... (다른 약관 전체 선택) ...
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '전체 동의',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitData() async {
    if (!isAllChecked(_isChecked1, _isChecked2)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 약관에 동의해야 합니다.')));
      return;
    }

    final rrn = '${_rrnFirstController.text}-${_rrnSecondController.text}';
    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'rrn': rrn,
      'agreements': {
        'agreement1': _isChecked1,
        'agreement2': _isChecked2,
      },
    };

    try {
      await ApiService.submitData(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data submitted successfully')));
      _navigateToSuccessPage(rrn);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting data: $error')));
    }
  }

  void _navigateToSuccessPage(String rrn) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuccessPage(rrn: rrn)),
    );
  }

  String get _currentInputField {
    if (_phoneFocusNode.hasFocus) {
      return '휴대폰 번호 입력';
    } else if (_rrnFirstFocusNode.hasFocus || _rrnSecondFocusNode.hasFocus) {
      return '주민등록번호 입력';
    } else if (_nameFocusNode.hasFocus) {
      return '이름 입력';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "본인인증",
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // 메인 타이틀
            Center(
              child: Text(
                _currentInputField,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),

            // 휴대폰 번호
            if (_isRrnEntered) ...[
              PhoneNumberField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
                onChanged: _handlePhoneInput,
              ),
            ],
            SizedBox(height: 10),

            // 주민등록번호
            if (_isNameEntered) ...[
              RrnField(
                firstFocusNode: _rrnFirstFocusNode,
                secondFocusNode: _rrnSecondFocusNode,
                firstController: _rrnFirstController,
                secondController: _rrnSecondController,
                onChanged: _handleRrnInput,
                onFirstFieldCompleted: _handleRrnFirstFieldCompleted,
              ),
            ],
            
            // 이름
            NameField(
              focusNode: _nameFocusNode,
              controller: _nameController,
              onSubmitted: _handleNameSubmit,
            ),
            SizedBox(height: 20),
            if (!_isNameEntered) ...[
              Center(
                child: ElevatedButton(
                  onPressed: _handleNameSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: inputPadding,
                    textStyle: buttonTextStyle,
                  ),
                  child: Text('이름 입력 완료'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}