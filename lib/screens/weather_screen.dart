import 'package:flutter/material.dart';
import '../models/weather_result.dart';
import '../services/weather_service.dart';
import '../models/hourly_forecast.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();

  WeatherResult? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather(); // Se ejecuta automáticamente al abrir la pantalla
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _service.getWeather();
      setState(() => _weather = weather);
    } catch (e) {
      setState(() => _errorMessage = 'No se pudo obtener el clima.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isCurrentHour(String forecastTime) {
  try {
    final now = DateTime.now();
    final fTime = DateTime.parse(forecastTime);
    return fTime.hour == now.hour;
  } catch (_) {
    return false;
  }
}

  // Color de fondo según el clima
  Color _getBackgroundColor() {
    if (_weather == null) return Colors.blue.shade100;
    final code = _weather!.weatherCode;
    if (code == 0) return Colors.orange.shade100;
    if (code <= 2) return Colors.blue.shade100;
    if (code == 3) return Colors.grey.shade300;
    if (code <= 69) return Colors.blueGrey.shade100;
    if (code <= 99) return Colors.deepPurple.shade100;
    return Colors.blue.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en RD'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón para recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBackgroundColor(),
              Colors.white,
            ],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWeather,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_weather == null) return const SizedBox();

    return SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Column(
    children: [
      const SizedBox(height: 20),

      // Ciudad
      const Text(
        '📍 Santo Domingo, RD',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
      const SizedBox(height: 8),

      // Fecha actual
      Text(
        _formatDate(_weather!.time),
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 32),

      // Emoji grande
      Text(_weather!.emoji, style: const TextStyle(fontSize: 100)),
      const SizedBox(height: 16),

      // Temperatura
      Text(
        '${_weather!.temperature.toStringAsFixed(1)}°C',
        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      // Descripción precisa
      Text(
        _weather!.description,
        style: const TextStyle(fontSize: 22, color: Colors.black54),
      ),
      const SizedBox(height: 40),

      // Tarjetas humedad y viento
      Row(
        children: [
          _WeatherDetailCard(
            icon: Icons.water_drop,
            label: 'Humedad',
            value: '${_weather!.humidity}%',
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          _WeatherDetailCard(
            icon: Icons.air,
            label: 'Viento',
            value: '${_weather!.windSpeed} km/h',
            color: Colors.teal,
          ),
        ],
      ),
      const SizedBox(height: 32),

      // ── Pronóstico por hora ──────────────────────────
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Pronóstico del día',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 12),

      SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _weather!.hourlyForecasts.length,
          itemBuilder: (context, index) {
            final forecast = _weather!.hourlyForecasts[index];
            final isNow = _isCurrentHour(forecast.time);

            return _HourlyCard(
              forecast: forecast,
              isNow: isNow,
            );
          },
        ),
      ),
    ],
  ),
);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      const days = [
        '', 'Lunes', 'Martes', 'Miércoles',
        'Jueves', 'Viernes', 'Sábado', 'Domingo'
      ];
      return '${days[date.weekday]}, ${date.day} de ${months[date.month]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
    
  }
}

class _WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherDetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
    
  }
  


}

class _HourlyCard extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isNow;

  const _HourlyCard({required this.forecast, required this.isNow});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.parse(forecast.time).hour;
    final label = isNow ? 'Ahora' : '${hour.toString().padLeft(2, '0')}:00';

    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isNow ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow ? Colors.blue : Colors.grey.shade300,
          width: isNow ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isNow ? Colors.white : Colors.grey,
            ),
          ),
          Text(
            WeatherResult.getEmoji(forecast.weatherCode),
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            '${forecast.temperature.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isNow ? Colors.white : Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                size: 10,
                color: isNow ? Colors.white70 : Colors.blue,
              ),
              const SizedBox(width: 2),
              Text(
                '${forecast.precipitationProbability}%',
                style: TextStyle(
                  fontSize: 10,
                  color: isNow ? Colors.white70 : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}