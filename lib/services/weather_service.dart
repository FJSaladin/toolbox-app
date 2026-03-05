import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_result.dart';

class WeatherService {
  static const String _url =
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=18.4861'
    '&longitude=-69.9312'
    '&current=temperature_2m,weathercode,windspeed_10m,relative_humidity_2m'
    '&hourly=temperature_2m,weathercode,precipitation_probability'
    '&timezone=America/Santo_Domingo'
    '&forecast_days=1';

  Future<WeatherResult> getWeather() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      return WeatherResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener el clima');
    }
  }
}