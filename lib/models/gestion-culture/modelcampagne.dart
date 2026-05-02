class Campagne {
  final int id_camp;
  final String nom_camp;
  final String date_debut;
  final String date_fin;
  final int code_expl;
  final int id_cham;
  final String statut;

  Campagne({
    required this.id_camp,
    required this.nom_camp,
    required this.date_debut,
    required this.date_fin,
    required this.code_expl,
    required this.id_cham,
    required this.statut,


  });

  factory Campagne.fromJson(Map<String, dynamic> json) {

    return Campagne(
      id_camp: json['id_camp'],
      nom_camp: json['nom_camp'],
      date_debut: json['date_debut'],
      date_fin: json['date_fin'],
      code_expl: json['code_expl'],
      id_cham: json['id_cham'],
      statut: json['statut'],


    );

  }

  Map<String, dynamic> toJson() {

    return {
      "id_camp": id_camp,
      "nom_camp": nom_camp,
      "date_debut": date_debut,
      "date_fin": date_fin,
      "code_expl": code_expl,
      "id_cham": id_cham,
      "statut": statut,


    };

  }

}