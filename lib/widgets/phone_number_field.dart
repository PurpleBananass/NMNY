import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/styles.dart';

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
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: '휴대폰 번호',
        labelStyle: labelTextStyle,
        hintText: "'-' 없이 입력",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        PhoneNumberFormatter(),
      ],
      style: inputTextStyle,
      textAlign: focusNode.hasFocus ? TextAlign.left : TextAlign.center,
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

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