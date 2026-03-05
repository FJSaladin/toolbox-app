import 'package:flutter/material.dart';
import '../models/gender_result.dart';
import '../services/gender_service.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final TextEditingController _controller = TextEditingController();
  final GenderService _service = GenderService();

  GenderResult? _result;   // null = aún no hay resultado
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
      final result = await _service.predictGender(name);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo obtener el resultado. Intenta de nuevo.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictor de Género'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Campo de texto
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Escribe un nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _predict(),
            ),
            const SizedBox(height: 16),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _predict,
                child: const Text('Predecir', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),

            // Estados: cargando, error, o resultado
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

  Widget _buildResult(GenderResult result) {
    final isMale = result.gender == 'male';
    final color = isMale ? Colors.blue : Colors.pink;
    final emoji = isMale ? '👨' : '👩';
    final label = isMale ? 'Masculino' : 'Femenino';
    final percent = (result.probability * 100).toStringAsFixed(0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 12),
          Text(
            result.name.toUpperCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Probabilidad: $percent%',
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}