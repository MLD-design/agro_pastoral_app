class RapportCulture {

  final String parcelle;

  final String campagne;

  final int quantiteSemence;

  final int nombreTraitements;

  final int nombreRecoltes;

  final String statutRecolte;

  final List<dynamic> notesAudio;

  RapportCulture({

    required this.parcelle,

    required this.campagne,

    required this.quantiteSemence,

    required this.nombreTraitements,

    required this.nombreRecoltes,

    required this.statutRecolte,

    required this.notesAudio,

  });

  factory RapportCulture.fromJson(Map<String, dynamic> json) {

    return RapportCulture(

      parcelle: json['parcelle']['nom_cham'],

      campagne: json['campagne']['nom_camp'],

      quantiteSemence: json['quantite_semence'],

      nombreTraitements: json['nombre_traitements'],

      nombreRecoltes: json['nombre_recoltes'],

      statutRecolte: json['statut_recolte'],

      notesAudio: json['notes_audio'] ?? [],

    );

  }

}