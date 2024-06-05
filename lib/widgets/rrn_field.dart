import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/styles.dart';

class RrnField extends StatelessWidget {
  final FocusNode firstFocusNode;
  final FocusNode secondFocusNode;
  final TextEditingController firstController;
  final TextEditingController secondController;
  final Function onChanged;
  final Function(String) onFirstFieldCompleted;

  const RrnField({
    Key? key,
    required this.firstFocusNode,
    required this.secondFocusNode,
    required this.firstController,
    required this.secondController,
    required this.onChanged,
    required this.onFirstFieldCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: firstFocusNode,
          controller: firstController,
          decoration: InputDecoration(
            labelText: '주민등록번호 앞자리',
            labelStyle: labelTextStyle,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (value) {
            onChanged();
            if (value.length == 6) {
              onFirstFieldCompleted(value);
            }
          },
          style: inputTextStyle,
          textAlign: firstFocusNode.hasFocus ? TextAlign.left : TextAlign.center,
        ),
        Center(child: Text('-', style: TextStyle(fontSize: 60))),
        TextField(
          focusNode: secondFocusNode,
          controller: secondController,
          decoration: InputDecoration(
            labelText: '주민등록번호 뒷자리',
            labelStyle: labelTextStyle,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: (_) => onChanged(),
          style: inputTextStyle,
          textAlign: secondFocusNode.hasFocus ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}