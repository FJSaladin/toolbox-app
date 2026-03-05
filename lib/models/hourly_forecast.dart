class HourlyForecast {
  final String time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });
}