import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  const PhoneNumberField({
    Key? key,
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: InputDecoration(
            labelText: '휴대폰 번호',
            labelStyle: TextStyle(fontSize: 30),
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
          textAlign: focusNode.hasFocus ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    const maxLength = 11;

    for (int i = 0; i < digits.length && i < maxLength; i++) {
      buffer.write(digits[i]);
      if ((i == 2 || i == 6) && i != digits.length - 1) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}