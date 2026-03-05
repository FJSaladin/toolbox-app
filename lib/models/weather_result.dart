import 'hourly_forecast.dart';

class WeatherResult {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final String time;
  final List<HourlyForecast> hourlyForecasts;

  WeatherResult({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.time,
    required this.hourlyForecasts,
  });

  factory WeatherResult.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourly = json['hourly'];

    // Construimos la lista de pronósticos por hora
    final List<HourlyForecast> forecasts = [];
    final times = hourly['time'] as List<dynamic>;

    for (int i = 0; i < times.length; i++) {
      forecasts.add(HourlyForecast(
        time: times[i],
        temperature: (hourly['temperature_2m'][i] as num).toDouble(),
        weatherCode: hourly['weathercode'][i] as int,
        precipitationProbability:
            hourly['precipitation_probability'][i] as int,
      ));
    }

    return WeatherResult(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weathercode'] as int,
      windSpeed: (current['windspeed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
      time: current['time'] as String,
      hourlyForecasts: forecasts,
    );
  }

  // ── Descripción precisa por código WMO ──────────────────────────
  static String getDescription(int code) {
    switch (code) {
      case 0:   return 'Cielo despejado';
      case 1:   return 'Principalmente despejado';
      case 2:   return 'Parcialmente nublado';
      case 3:   return 'Nublado';
      case 45:  return 'Niebla';
      case 48:  return 'Niebla con escarcha';
      case 51:  return 'Llovizna ligera';
      case 53:  return 'Llovizna moderada';
      case 55:  return 'Llovizna densa';
      case 56:  return 'Llovizna helada ligera';
      case 57:  return 'Llovizna helada densa';
      case 61:  return 'Lluvia ligera';
      case 63:  return 'Lluvia moderada';
      case 65:  return 'Lluvia intensa';
      case 66:  return 'Lluvia helada ligera';
      case 67:  return 'Lluvia helada intensa';
      case 71:  return 'Nevada ligera';
      case 73:  return 'Nevada moderada';
      case 75:  return 'Nevada intensa';
      case 77:  return 'Granizo fino';
      case 80:  return 'Chubascos ligeros';
      case 81:  return 'Chubascos moderados';
      case 82:  return 'Chubascos violentos';
      case 85:  return 'Chubascos de nieve ligeros';
      case 86:  return 'Chubascos de nieve intensos';
      case 95:  return 'Tormenta eléctrica';
      case 96:  return 'Tormenta con granizo ligero';
      case 99:  return 'Tormenta con granizo intenso';
      default:  return 'Condición desconocida';
    }
  }

  static String getEmoji(int code) {
    switch (code) {
      case 0:         return '☀️';
      case 1:         return '🌤️';
      case 2:         return '⛅';
      case 3:         return '☁️';
      case 45:
      case 48:        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:        return '🌦️';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:        return '❄️';
      case 80:
      case 81:
      case 82:        return '🌨️';
      case 85:
      case 86:        return '☃️';
      case 95:        return '⛈️';
      case 96:
      case 99:        return '🌩️';
      default:        return '🌡️';
    }
  }

  // Getters que usan los métodos estáticos para el clima actual
  String get description => getDescription(weatherCode);
  String get emoji => getEmoji(weatherCode);
}