class AgeResult {
  final String name;
  final int age;

  AgeResult({
    required this.name,
    required this.age,
  });
  
factory AgeResult.fromJson(Map<String, dynamic> json){
  return AgeResult(name: json['name'], age: json['age'] ?? 0,
  );
}

    String get lifeStage{
      if (age < 18 ) return 'Joven';
      if (age < 60 ) return 'Adulto';
      return 'Anciano';
    }
  }
 
  