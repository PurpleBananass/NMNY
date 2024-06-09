import 'package:flutter/material.dart';

class MedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('의약품 세부 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeader('의약품 정보'),
            _buildInfoItem('의약품명', medication['DrugList'][0]['Name']),
            _buildInfoItem('영문 의약품명', medication['DrugList'][0]['Name']),
            _buildInfoItem('제조회사', medication['Dispensary']),
            _buildInfoItem('전화번호', medication['PhoneNumber']),
            _buildInfoItem('준비일자', medication['DateOfPreparation']),
            _buildInfoItem('번호', medication['No']),
            SizedBox(height: 16),
            _buildHeader('약품 상세 정보'),
            ...medication['DrugList'].map<Widget>((drug) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('효능', drug['Effect']),
                      _buildInfoItem('성분', drug['Component']),
                      _buildInfoItem('수량', drug['Quantity']),
                      _buildInfoItem('1회 복용량', drug['DosagePerOnce']),
                      _buildInfoItem('일일 복용량', drug['DailyDose']),
                      _buildInfoItem('총 복용일수', drug['TotalDosingDays']),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}