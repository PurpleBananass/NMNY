import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<void> submitData(Map<String, dynamic> data) async {
    final url = Uri.parse(apiUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // print('Data submitted successfully');
        return;
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (error) {
      throw Exception('Error submitting data: $error');
    }
  }
}