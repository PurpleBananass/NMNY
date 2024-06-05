import 'package:flutter/material.dart';
import '../utils/styles.dart';

class NameField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function onSubmitted;

  const NameField({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: '이름을 입력하세요.',
        labelStyle: labelTextStyle,
        border: OutlineInputBorder(),
      ),
      onSubmitted: (value) => onSubmitted(),
      style: inputTextStyle,
      textAlign: focusNode.hasFocus ? TextAlign.left : TextAlign.center,
    );
  }
}