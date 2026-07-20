// Une ligne de gain ou de retenue (ex: "Prime de transport" -> 15000,
// "IPRES (retraite)" -> 8400). Remplace les anciens champs "primes"/
// "retenues" à valeur unique par des listes détaillées.
class LignePaie {
  final String libelle;
  final double montant;

  LignePaie({required this.libelle, required this.montant});

  factory LignePaie.fromJson(Map<String, dynamic> json) {
    return LignePaie(
      libelle: json['libelle']?.toString() ?? '',
      montant: (json['montant'] is num) ? (json['montant'] as num).toDouble() : double.tryParse(json['montant'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"libelle": libelle, "montant": montant};
}

class Paiement {
  int id_paiement;
  int employeId;
  String? employeNom;
  String? employePoste;
  int code_expl;
  String mois;
  int annee;
  double salaireBase;
  List<LignePaie> primes;
  List<LignePaie> retenues;
  String statut;

  Paiement({
    required this.id_paiement,
    required this.employeId,
    this.employeNom,
    this.employePoste,
    required this.code_expl,
    required this.mois,
    required this.annee,
    required this.salaireBase,
    required this.primes,
    required this.retenues,
    required this.statut,
  });

  double get totalPrimes => primes.fold(0.0, (s, p) => s + p.montant);
  double get totalRetenues => retenues.fold(0.0, (s, r) => s + r.montant);
  double get brut => salaireBase + totalPrimes;
  double get net => brut - totalRetenues;

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id_paiement: int.parse(json['id_paiement'].toString()),
      employeId: int.parse(json['employeId'].toString()),
      employeNom: json['employeNom']?.toString(),
      employePoste: json['employePoste']?.toString(),
      code_expl: int.parse(json['code_expl'].toString()),
      mois: json['mois'],
      annee: int.parse(json['annee'].toString()),
      salaireBase: double.parse(json['salaireBase'].toString()),
      primes: (json['primes'] as List? ?? []).map((e) => LignePaie.fromJson(Map<String, dynamic>.from(e))).toList(),
      retenues: (json['retenues'] as List? ?? []).map((e) => LignePaie.fromJson(Map<String, dynamic>.from(e))).toList(),
      statut: json['statut'],
    );
  }

  Map<String, dynamic> toJson() => {
    "employeId": employeId,
    "employeNom": employeNom,
    "employePoste": employePoste,
    "code_expl": code_expl,
    "mois": mois,
    "annee": annee,
    "salaireBase": salaireBase,
    "primes": primes.map((p) => p.toJson()).toList(),
    "retenues": retenues.map((r) => r.toJson()).toList(),
  };
}
