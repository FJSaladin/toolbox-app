import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/university.dart';
import '../services/university_service.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final TextEditingController _controller = TextEditingController();
  final UniversityService _service = UniversityService();

  List<University> _universities = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchedCountry = '';

  Future<void> _search() async {
    final country = _controller.text.trim();
    if (country.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _universities = [];
      _searchedCountry = country;
    });

    try {
      final results = await _service.getUniversities(country);
      setState(() => _universities = results);

      if (results.isEmpty) {
        setState(() => _errorMessage = 'No se encontraron universidades para "$country".');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error al buscar. Verifique que el nombre del país este correctamente escrito en inglés.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades por País'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Sección de búsqueda (fija arriba)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Escriba el nombre del país en inglés (ej: Dominican Republic)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Contador de resultados
          if (_universities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_universities.length} universidades en $_searchedCountry',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

          // Área de resultados (scrolleable)
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 15),
          ),
        ),
      );
    }

    if (_universities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Busca un país para ver\nsus universidades',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Lista de universidades
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _universities.length,
      itemBuilder: (context, index) {
        return _UniversityCard(
          university: _universities[index],
          index: index + 1,
          onOpenUrl: _openUrl,
        );
      },
    );
  }
}

class _UniversityCard extends StatelessWidget {
  final University university;
  final int index;
  final Function(String) onOpenUrl;

  const _UniversityCard({
    required this.university,
    required this.index,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    university.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dominio
            if (university.domains.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.language, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    university.domains.first,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Links a páginas web
            ...university.webPages.map(
              (url) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => onOpenUrl(url),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new, size: 16, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          url,
                          style: const TextStyle(
                            color: Colors.indigo,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}