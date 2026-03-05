import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/pokemon_result.dart';
import '../services/pokemon_service.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final TextEditingController _controller = TextEditingController();
  final PokemonService _service = PokemonService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PokemonResult? _pokemon;
  bool _isLoading = false;
  bool _isPlayingSound = false;
  String? _errorMessage;

  @override
  void dispose() {
    // IMPORTANTE: siempre liberar recursos de audio al salir
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokemon = null;
    });

    try {
      final result = await _service.getPokemon(name);
      setState(() => _pokemon = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playCry() async {
    if (_pokemon == null || _pokemon!.cryUrl.isEmpty) return;

    setState(() => _isPlayingSound = true);

    try {
      await _audioPlayer.setUrl(_pokemon!.cryUrl);
      await _audioPlayer.play();
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo reproducir el sonido')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlayingSound = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header rojo estilo Pokédex
          Container(
            color: Colors.red.shade400,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nombre del Pokémon...',
                      hintStyle: TextStyle(color: Colors.red.shade100),
                      prefixIcon: const Icon(Icons.catching_pokemon, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😵', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_pokemon == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔴', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text(
              'Escribe el nombre de un Pokémon',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Ej: pikachu, charizard, mewtwo',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return _buildPokemonCard(_pokemon!);
  }

  Widget _buildPokemonCard(PokemonResult pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Imagen del Pokémon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
              ),
              pokemon.imageUrl.isNotEmpty
                  ? Image.network(
                      pokemon.imageUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const CircularProgressIndicator(color: Colors.red),
                    )
                  : const Icon(Icons.catching_pokemon, size: 120, color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Stats principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: 'Exp. Base', value: '${pokemon.baseExperience}', icon: '⭐'),
              _StatChip(label: 'Altura', value: '${pokemon.height / 10}m', icon: '📏'),
              _StatChip(label: 'Peso', value: '${pokemon.weight / 10}kg', icon: '⚖️'),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de sonido
          if (pokemon.cryUrl.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _isPlayingSound ? null : _playCry,
              icon: _isPlayingSound
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(_isPlayingSound ? 'Reproduciendo...' : '¡Escuchar grito!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          const SizedBox(height: 24),

          // Habilidades
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Habilidades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ...pokemon.abilities.map((ability) => _AbilityTile(ability: ability)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  final PokemonAbility ability;

  const _AbilityTile({required this.ability});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ability.isHidden ? Colors.purple.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ability.isHidden ? Colors.purple.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ability.isHidden ? Icons.visibility_off : Icons.flash_on,
            color: ability.isHidden ? Colors.purple : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ability.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          if (ability.isHidden)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Oculta',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}