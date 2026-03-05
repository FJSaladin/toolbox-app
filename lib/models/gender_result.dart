
class GenderResult{
  final String name;
  final String gender;
  final double probability;
  

  GenderResult({
    required this.name,
    required this.gender,
    required this.probability,
  });

  factory GenderResult.fromJson(Map<String, dynamic> json) {
    return GenderResult(
      name: json['name'],
      gender: json['gender'] ?? 'unknown',
      probability: (json['probability'] as num).toDouble(),
    );
  }
}


