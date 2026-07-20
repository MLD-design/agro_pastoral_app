class Campagne {
  final int id_camp;
  final String nom_camp;
  final String date_debut;
  final String date_fin;
  final int code_expl;
  final int id_cham;
  final String statut;

  // --- NOUVELLES PROPRIÉTÉS AJOUTÉES ---
  final String etape_actuelle;   // Récupère 'Semis', 'Traitement' ou 'Récoltée'
  final double quantite_recoltee; // Stocke la quantité finale mesurée sur le terrain
  final String status_couleur;   // Récupère la couleur dynamique ('VERT', 'ORANGE', 'ROUGE')

  Campagne({
    required this.id_camp,
    required this.nom_camp,
    required this.date_debut,
    required this.date_fin,
    required this.code_expl,
    required this.id_cham,
    required this.statut,
    required this.etape_actuelle,
    required this.quantite_recoltee,
    required this.status_couleur,
  });

  factory Campagne.fromJson(Map<String, dynamic> json) {
    return Campagne(
      id_camp: json['id_camp'] ?? 0,
      nom_camp: json['nom_camp'] ?? '',
      date_debut: json['date_debut'] ?? '',
      date_fin: json['date_fin'] ?? '',
      // Sécurisation du parsing des entiers et des doubles
      code_expl: json['code_expl'] is String ? int.parse(json['code_expl']) : (json['code_expl'] ?? 0),
      id_cham: json['id_cham'] is String ? int.parse(json['id_cham']) : (json['id_cham'] ?? 0),
      statut: json['statut'] ?? 'Planifié',

      // Extraction des clés enrichies du backend
      etape_actuelle: json['etape_actuelle'] ?? 'Semis',
      quantite_recoltee: (json['quantite_recoltee'] as num? ?? 0.0).toDouble(),
      status_couleur: json['status_couleur'] ?? 'VERT',
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

      // Envoi des états à la création ou mise à jour
      "etape_actuelle": etape_actuelle,
      "quantite_recoltee": quantite_recoltee,
      "status_couleur": status_couleur,
    };
  }
}