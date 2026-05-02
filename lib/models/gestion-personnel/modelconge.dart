class Conge {
  int id_conge;
  int employeId;
  String type;
  String dateDebut;
  String dateFin;
  String statut;
  int code_expl;

  Conge({
    required this.id_conge,
    required this.employeId,
    required this.type,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.code_expl,
  });

  factory Conge.fromJson(Map<String, dynamic> json) {
    return Conge(
      id_conge: int.parse(json['id_conge'].toString()),
      employeId: int.parse(json['employeId'].toString()),
      type: json['type'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      statut: json['statut'],
      code_expl: int.parse(json['code_expl'].toString()),
    );
  }
}
