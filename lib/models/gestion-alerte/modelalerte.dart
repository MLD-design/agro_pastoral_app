class Alerte {
  final int idAlerte;
  final String type;
  final double valeur;
  final double seuil;
  final String message;
  final String codeExpl;
  final String date;
  final String statut;

  Alerte({
    required this.idAlerte,
    required this.type,
    required this.valeur,
    required this.seuil,
    required this.message,
    required this.codeExpl,
    required this.date,
    required this.statut,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      idAlerte: json['id_alerte'],
      type: json['type'],
      valeur: (json['valeur'] as num).toDouble(),
      seuil: (json['seuil'] as num).toDouble(),
      message: json['message'],
      codeExpl: json['code_expl'],
      date: json['date'],
      statut: json['statut'],
    );
  }
}
