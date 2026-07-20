class Stock {
  final String id_stock;   // ✅ String car backend renvoie Date.now().toString()
  final String nom;
  final String type;
  final int quantite;
  final int seuilAlerte;
  final String date;
  final String unite;
  final int code_expl;
  final String? imagePath;

  Stock({
    required this.id_stock,
    required this.nom,
    required this.type,
    required this.quantite,
    required this.seuilAlerte,
    required this.date,
    required this.unite,
    required this.code_expl,
    this.imagePath,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id_stock: json['id_stock'].toString(), // ✅ conversion en String
      nom: json['nom'],
      type: json['type'],
      quantite: json['quantite'],
      seuilAlerte: json['seuilAlerte'],
      date: json['date'],
      unite: json['unite'],
      code_expl: json['code_expl'] is int
          ? json['code_expl']
          : int.parse(json['code_expl'].toString()),
      imagePath: json['imagePath'],
    );
  }
}
