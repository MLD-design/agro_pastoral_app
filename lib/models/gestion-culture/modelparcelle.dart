class Parcelle {
  final int id_cham;
  final String nom_cham;
  int code_expl;


  Parcelle({
    required this.id_cham,
    required this.nom_cham,
    required this.code_expl,

  });

  factory Parcelle.fromJson(Map<String, dynamic> json) {
    return Parcelle(
        id_cham: int.tryParse(json['id_cham'].toString())?? 0,
        nom_cham: json['nom_cham']??'',
      code_expl: json['code_expl'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_champ": id_cham,
      "nom_cham": nom_cham,
      "code_expl":code_expl,

    };
  }
}