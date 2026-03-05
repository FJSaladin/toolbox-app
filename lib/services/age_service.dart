import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/age_result.dart';

class AgeService {
  static const String _baseUrl = 'https://api.agify.io';

  Future<AgeResult> predictAge(String name) async {
    final url = Uri.parse('$_baseUrl/?name=$name');

    final response = await http.get(url);
    if(response.statusCode==200){
      final json = jsonDecode(response.body);
      return AgeResult.fromJson(json);

    }else{
      throw Exception('Error al Conectar la API: ${response.statusCode}');
    }
  }
}