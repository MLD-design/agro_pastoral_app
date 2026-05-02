class Depense {

  final String libelle;

  final int montant;

  Depense({required this.libelle, required this.montant});

  factory Depense.fromJson(Map<String, dynamic> json) {

    return Depense(

      libelle: json['libelle'],

      montant: json['montant'],

    );

  }

}

class Recette {

  final String source;

  final int montant;

  Recette({required this.source, required this.montant});

  factory Recette.fromJson(Map<String, dynamic> json) {

    return Recette(

      source: json['source'],

      montant: json['montant'],

    );

  }

}