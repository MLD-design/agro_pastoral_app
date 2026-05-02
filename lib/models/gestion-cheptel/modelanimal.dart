class Animal {
  final int animalId;
  final String identifiant;
  final String race;
  final int age;
  final String sexe;
  final int codeExpl;

  Animal({
    required this.animalId,
    required this.identifiant,
    required this.race,
    required this.age,
    required this.sexe,
    required this.codeExpl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      animalId: json['animalId'],
      identifiant: json['identifiant'],
      race: json['race'],
      age: json['age'],
      sexe: json['sexe'],
      codeExpl: int.parse(json['code_expl']),
    );
  }
}
