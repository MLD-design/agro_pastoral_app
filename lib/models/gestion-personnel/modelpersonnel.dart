class Personnel {
  final int code_per;
  final String nom;
  final String poste;
  final double salaire;
  final int code_expl;
  final int? userId; // 🔴 Ajout du champ userId (nullable)

  Personnel({
    required this.code_per,
    required this.nom,
    required this.poste,
    required this.salaire,
    required this.code_expl,
    this.userId, // Optionnel au début
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      code_per: json['code_per'],
      nom: json['nom'],
      poste: json['poste'],
      salaire: ConvertToDouble(json['salaire']),
      code_expl: json['code_expl'],
      userId: json['userId'], // 🔴 Récupération depuis l'API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_per': code_per,
      'nom': nom,
      'poste': poste,
      'salaire': salaire,
      'code_expl': code_expl,
      'userId': userId,
    };
  }
}

// Petite fonction utilitaire pour gérer les types de salaire (int ou double) venant du JSON
double ConvertToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  return value as double;
}