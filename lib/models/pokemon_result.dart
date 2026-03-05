class PokemonAbility {
  final String name;
  final bool isHidden;

  PokemonAbility({required this.name, required this.isHidden});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['ability']['name'],
      isHidden: json['is_hidden'],
    );
  }
}

class PokemonResult {
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final String imageUrl;
  final String cryUrl;
  final List<PokemonAbility> abilities;

  PokemonResult({
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.cryUrl,
    required this.abilities,
  });

  factory PokemonResult.fromJson(Map<String, dynamic> json) {
    return PokemonResult(
      name: json['name'],
      baseExperience: json['base_experience'] ?? 0,
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      // Imagen oficial de alta calidad
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ?? '',
      // Sonido más reciente
      cryUrl: json['cries']['latest'] ?? '',
      abilities: (json['abilities'] as List)
          .map((a) => PokemonAbility.fromJson(a))
          .toList(),
    );
  }
}