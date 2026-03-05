import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gender_result.dart';

class GenderService {
  static const String _baseUrl = 'https://api.genderize.io';

  Future<GenderResult> predictGender(String name) async {
    final url = Uri.parse('$_baseUrl/?name=$name');

    final response = await http.get(url);
    if(response.statusCode==200){
      final json = jsonDecode(response.body);
      return GenderResult.fromJson(json);

    }else{
      throw Exception('Error al Conectar la API: ${response.statusCode}');
    }
  }
}