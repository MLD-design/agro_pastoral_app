class Production {
  final int id;
  final int animalId;
  final int lait;
  final int viande;
  final int codeExpl;

  Production({
    required this.id,
    required this.animalId,
    required this.lait,
    required this.viande,
    required this.codeExpl,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      animalId: json['animalId'],
      lait: json['lait'],
      viande: json['viande'],
      codeExpl: int.parse(json['code_expl']),
    );
  }
}
