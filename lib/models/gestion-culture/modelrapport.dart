// lib/models/gestion-culture/modelrapport.dart
class RapportCulture {
  final String nomCampagne;
  final String nomParcelle;

  final bool semisValide;
  final String? dateSemis;
  final String? variete;
  final double quantiteSemee;

  final bool leveeValidee;
  final String? tauxLevee;

  final int nombreObservations;

  final bool recolteCloturee;
  final String? dateCloture;
  final int nombrePassagesRecolte;
  final double quantiteTotaleRecoltee;
  final String? uniteRecolte;

  final int nombreTraitements;
  final String statutGlobal; // 'EN_COURS' | 'RECOLTEE' | 'RETARD'

  RapportCulture({
    required this.nomCampagne,
    required this.nomParcelle,
    required this.semisValide,
    this.dateSemis,
    this.variete,
    required this.quantiteSemee,
    required this.leveeValidee,
    this.tauxLevee,
    required this.nombreObservations,
    required this.recolteCloturee,
    this.dateCloture,
    required this.nombrePassagesRecolte,
    required this.quantiteTotaleRecoltee,
    this.uniteRecolte,
    required this.nombreTraitements,
    required this.statutGlobal,
  });

  factory RapportCulture.fromJson(Map<String, dynamic> json) {
    final semis = json['semis'] ?? {};
    final levee = json['levee'] ?? {};
    final recolte = json['recolte'] ?? {};

    return RapportCulture(
      nomCampagne: json['campagne']?['nom_camp']?.toString() ?? '',
      nomParcelle: json['parcelle']?['nom_cham']?.toString() ?? '',
      semisValide: semis['valide'] == true,
      dateSemis: semis['date']?.toString(),
      variete: semis['variete']?.toString(),
      quantiteSemee: (semis['quantite_semee'] as num? ?? 0).toDouble(),
      leveeValidee: levee['valide'] == true,
      tauxLevee: levee['taux_levee']?.toString(),
      nombreObservations: json['nombre_observations'] is int ? json['nombre_observations'] : 0,
      recolteCloturee: recolte['cloturee'] == true,
      dateCloture: recolte['date_cloture']?.toString(),
      nombrePassagesRecolte: recolte['nombre_passages'] is int ? recolte['nombre_passages'] : 0,
      quantiteTotaleRecoltee: (recolte['quantite_totale'] as num? ?? 0).toDouble(),
      uniteRecolte: recolte['unite']?.toString(),
      nombreTraitements: json['nombre_traitements'] is int ? json['nombre_traitements'] : 0,
      statutGlobal: json['statut_global']?.toString() ?? 'EN_COURS',
    );
  }
}
