class Paiement {
  int id_paiement;
  int employeId;
  int code_expl;
  String mois;
  int annee;
  double salaireBase;
  double primes;
  double retenues;
  double net;
  String statut;

  Paiement({
    required this.id_paiement,
    required this.employeId,
    required this.code_expl,
    required this.mois,
    required this.annee,
    required this.salaireBase,
    required this.primes,
    required this.retenues,
    required this.net,
    required this.statut,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id_paiement: int.parse(json['id_paiement'].toString()),
      employeId: int.parse(json['employeId'].toString()),
      code_expl: int.parse(json['code_expl'].toString()),
      mois: json['mois'],
      annee: int.parse(json['annee'].toString()),
      salaireBase: double.parse(json['salaireBase'].toString()),
      primes: double.parse(json['primes'].toString()),
      retenues: double.parse(json['retenues'].toString()),
      net: double.parse(json['net'].toString()),
      statut: json['statut'],
    );
  }
}
