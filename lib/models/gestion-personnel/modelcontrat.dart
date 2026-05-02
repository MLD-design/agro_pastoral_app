class Contrat {
  int id_contrat;
  int employeId;
  int code_expl;
  String type;
  String dateDebut;
  String dateFin;
  String? contratUrl;

  Contrat({
    required this.id_contrat,
    required this.employeId,
    required this.code_expl,
    required this.type,
    required this.dateDebut,
    required this.dateFin,
    this.contratUrl,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id_contrat: int.tryParse(json['id_contrat'].toString()) ?? 0,
      employeId: int.tryParse(json['employeId'].toString()) ?? 0,
      code_expl: int.tryParse(json['code_expl'].toString()) ?? 0,
      type: json['type'] ?? "",
      dateDebut: json['dateDebut'] ?? "",
      dateFin: json['dateFin'] ?? "",
      contratUrl: json['contrat_url'],
    );
  }
}
