import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/university.dart';

class UniversityService {
  static const String _baseUrl = 'https://adamix.net/proxy.php';

  Future<List<University>> getUniversities(String country) async {
    final url = Uri.parse('$_baseUrl?country=${Uri.encodeComponent(country)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      // Convertimos cada elemento del array en un objeto University
      return jsonList.map((json) => University.fromJson(json)).toList();
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}