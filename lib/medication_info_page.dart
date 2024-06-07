import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationInfoPage extends StatefulWidget {
  @override
  _MedicationInfoPageState createState() => _MedicationInfoPageState();
}

class _MedicationInfoPageState extends State<MedicationInfoPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicationInfo();
  }

  Future<void> _fetchMedicationInfo() async {
    final url = Uri.parse('http://your-server-address/api/medication'); // Replace with your actual API URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _medications = data['ResultList'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '의약품명: ${medication['DrugList'][0]['Name']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('영문 의약품명: ${medication['DrugList'][0]['Name']}'),
            Text('제조회사: ${medication['Dispensary']}'),
            Text('전화번호: ${medication['PhoneNumber']}'),
            Text('준비일자: ${medication['DateOfPreparation']}'),
            Text('번호: ${medication['No']}'),
            SizedBox(height: 16),
            ...medication['DrugList'].map<Widget>((drug) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('효능: ${drug['Effect']}'),
                    Text('성분: ${drug['Component']}'),
                    Text('수량: ${drug['Quantity']}'),
                    Text('1회 복용량: ${drug['DosagePerOnce']}'),
                    Text('일일 복용량: ${drug['DailyDose']}'),
                    Text('총 복용일수: ${drug['TotalDosingDays']}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약 상세정보'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Error fetching data'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    return _buildMedicationCard(_medications[index]);
                  },
                ),
    );
  }
}
