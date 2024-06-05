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
  final bool _isChecked1 = false;
  final bool _isChecked2 = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('간편인증 요청을 위해'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRrnEntered)
              PhoneNumberField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
              ),
            SizedBox(height: 10),
            if (_isNameEntered)
              RrnField(
                firstFocusNode: _rrnFirstFocusNode,
                secondFocusNode: _rrnSecondFocusNode,
                firstController: _rrnFirstController,
                secondController: _rrnSecondController,
                onChanged: _handleRrnInput,
                onFirstFieldCompleted: _handleRrnFirstFieldCompleted,
              ),
            NameField(
              focusNode: _nameFocusNode,
              controller: _nameController,
              onSubmitted: _handleNameSubmit,
            ),
            SizedBox(height: 20),
            if (!_isNameEntered) 
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
          ],
        ),
      ),
    );
  }
}