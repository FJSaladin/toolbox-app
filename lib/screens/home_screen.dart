import 'package:flutter/material.dart';
import 'gender_screen.dart';
import 'age_screen.dart';
import 'universities_screen.dart';
import 'weather_screen.dart';
import 'pokemon_screen.dart';
import 'news_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧰 Herramientas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Seleccione una Herramienta', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            _MenuButton(
              icon: Icons.help, 
              label: 'Predictor de Género',
              color: Colors.purple,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> const GenderScreen()),);
              },
              ),
              _MenuButton(
                  icon: Icons.cake,
                  label: 'Predictor de Edad',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AgeScreen()),
                    );
                  },
                ),
                _MenuButton(
                  icon: Icons.school,
                  label: 'Universidades por País',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UniversitiesScreen()),
                    );
                  },
                ),
                _MenuButton(
                    icon: Icons.wb_sunny,
                    label: 'Clima en Santo Domingo Rep. Dom.',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WeatherScreen()),
                      );
                    },
                  ),
                  _MenuButton(
                    icon: Icons.catching_pokemon,
                    label: 'Pokédex',
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PokemonScreen()),
                      );
                    },
                  ),
                  _MenuButton(
                    icon: Icons.newspaper,
                    label: 'Noticias',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewsScreen()),
                      );
                    },
                  ),
                  _MenuButton(
                      icon: Icons.info,
                      label: 'Acerca de',
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
          ],
        ),
      ),
    );

  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}