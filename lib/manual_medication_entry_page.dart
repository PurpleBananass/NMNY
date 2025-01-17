import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManualMedicationEntryPage extends StatefulWidget {
  const ManualMedicationEntryPage({super.key});

  @override
  ManualMedicationEntryPageState createState() => ManualMedicationEntryPageState();
}

class ManualMedicationEntryPageState extends State<ManualMedicationEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _preparationNoController = TextEditingController();
  final _preparationDateController = TextEditingController();
  final _dispensaryController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  List<Map<String, TextEditingController>> _drugControllers = [];
  int _drugCounter = 1;

  @override
  void dispose() {
    _preparationNoController.dispose();
    _preparationDateController.dispose();
    _dispensaryController.dispose();
    _phoneNumberController.dispose();
    for (var controllers in _drugControllers) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addDrug() {
    setState(() {
      _drugControllers.add({
        'No': TextEditingController(text: _drugCounter.toString()),
        'Name': TextEditingController(),
      });
      _drugCounter++;
    });
  }

  void _removeDrug(int index) {
    setState(() {
      _drugControllers.removeAt(index);
      _drugCounter--;
      // Reassign drug numbers
      for (int i = 0; i < _drugControllers.length; i++) {
        _drugControllers[i]['No']!.text = (i + 1).toString();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? rrn = prefs.getString('rrn');

      final drugList = _drugControllers.map((controllers) {
        return {
          'No': controllers['No']!.text,
          'Name': controllers['Name']!.text,

        };
      }).toList();

      final medicationInfo = {
        'RRN': rrn,
        'No': _preparationNoController.text,
        'DateOfPreparation': _preparationDateController.text,
        'Dispensary': _dispensaryController.text,
        'PhoneNumber': _phoneNumberController.text,
        'DrugList': drugList,
      };

      final url = Uri.parse('http://34.64.55.10:8080/add_medication');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode(medicationInfo);

      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('약 수기 작성이 완료되었습니다.')),
          );
          Navigator.pop(context); // Go back to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('약 수기 정보 제출 중 오류가 발생했습니다.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('약 수기 정보 제출 중 오류가 발생했습니다. $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약 수기 작성'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _preparationDateController,
                decoration: InputDecoration(labelText: '처방일자 (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    value = '-';
                    return null;
                  }
                  return null;
                },
                keyboardType: TextInputType.datetime,
                // inputFormatters: [
                //   FilteringTextInputFormatter.digitsOnly,
                //   LengthLimitingTextInputFormatter(8),
                // ],
              ),
              TextFormField(
                controller: _dispensaryController,
                decoration: InputDecoration(labelText: '조제기관'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    value = '-';
                    return null;
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              Text('Drugs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ..._drugControllers.asMap().entries.map((entry) {
                int index = entry.key;
                var controllers = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Drug ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeDrug(index),
                            ),
                          ],
                        ),
                        ...controllers.entries.map((controllerEntry) {
                          return TextFormField(
                            controller: controllerEntry.value,
                            decoration: InputDecoration(labelText: _getLabelText(controllerEntry.key)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ${controllerEntry.key}';
                              }
                              return null;
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addDrug,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('약 추가'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('작성 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
   String _getLabelText(String key) {
    switch (key) {
      case 'No':
        return '번호';
      case 'Name':
        return '제품명';
    
      default:
        return key;
    }
  }
}
