import 'package:flutter/material.dart';
import '../models/age_result.dart';
import '../services/age_service.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final TextEditingController _controller = TextEditingController();
  final AgeService _service = AgeService();

  AgeResult? _result;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _predict() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _service.predictAge(name);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _errorMessage = 'No se pudo obtener el resultado.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Configuración visual según etapa de vida
  Map<String, dynamic> _getStageConfig(String stage) {
    switch (stage) {
      case 'Joven':
        return {
          'color': Colors.green,
          'emoji': '🧑',
          
        };
      case 'Adulto':
        return {
          'color': Colors.orange,
          'emoji': '👨‍💼',

        };
      default: // Anciano
        return {
          'color': Colors.grey,
          'emoji': '👴',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictor de Edad'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Escribe un nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _predict(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _predict,
                child: const Text('Predecir edad', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_result != null)
              _buildResult(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(AgeResult result) {
    final config = _getStageConfig(result.lifeStage);
    final Color color = config['color'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          // Imagen representativa
          Text(
            config['emoji'],
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            result.name.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Edad en número grande
          Text(
            '${result.age} años',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Etiqueta de etapa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.lifeStage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mensaje motivacional
         
        ],
      ),
    );
  }
}