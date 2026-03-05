class University {
  final String name;
  final String country;
  final List<String> domains;
  final List<String> webPages;

  University({
    required this.name,
    required this.country,
    required this.domains,
    required this.webPages,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? 'Sin nombre',
      country: json['country'] ?? '',
      // La API devuelve listas, hay que castearlas correctamente
      domains: List<String>.from(json['domains'] ?? []),
      webPages: List<String>.from(json['web_pages'] ?? []),
    );
  }
}