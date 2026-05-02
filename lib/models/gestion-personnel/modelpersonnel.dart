class Personnel {
  int code_per;
  String nom;
  String poste;
  double salaire;
  int code_expl;

  Personnel({
    required this.code_per,
    required this.nom,
    required this.poste,
    required this.salaire,
    required this.code_expl,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      code_per: int.parse(json['code_per'].toString()), // ✅ CORRECT
      nom: json['nom'] ?? "",
      poste: json['poste'] ?? "",
      salaire: (json['salaire'] ?? 0).toDouble(),
      code_expl: int.parse(json['code_expl'].toString()), // ✅ CORRECT
    );

  }
}