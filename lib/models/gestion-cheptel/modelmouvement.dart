class Mouvement {
  final int id;
  final int animalId;
  final String type;
  final String date;
  final int quantite;
  final int codeExpl;

  Mouvement({
    required this.id,
    required this.animalId,
    required this.type,
    required this.date,
    required this.quantite,
    required this.codeExpl,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) {
    return Mouvement(
      id: json['id'],
      animalId: json['animalId'],
      type: json['type'],
      date: json['date'],
      quantite: json['quantite'],
      codeExpl: int.parse(json['code_expl']),
    );
  }
}
