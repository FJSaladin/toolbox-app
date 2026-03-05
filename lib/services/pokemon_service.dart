import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_result.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<PokemonResult> getPokemon(String name) async {
    // La API acepta nombre en minúsculas
    final url = Uri.parse('$_baseUrl/${name.toLowerCase().trim()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PokemonResult.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Pokémon "$name" no encontrado');
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}