class Reproduction {
  final int id;
  final int animalId;
  final String dateSaillie;
  final String dateMiseBas;
  final int codeExpl;

  Reproduction({
    required this.id,
    required this.animalId,
    required this.dateSaillie,
    required this.dateMiseBas,
    required this.codeExpl,
  });

  factory Reproduction.fromJson(Map<String, dynamic> json) {
    return Reproduction(
      id: json['id'],
      animalId: json['animalId'],
      dateSaillie: json['dateSaillie'],
      dateMiseBas: json['dateMiseBas'],
      codeExpl: int.parse(json['code_expl']),
    );
  }
}
