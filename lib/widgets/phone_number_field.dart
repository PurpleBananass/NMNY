import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/styles.dart';

class PhoneNumberField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function onChanged;

  const PhoneNumberField({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
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
          onChanged: (_) => onChanged(),
          style: inputTextStyle,
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