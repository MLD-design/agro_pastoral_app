class Stock {
  String id_stock;
  String nom;
  String type;
  int quantite;
  int seuilAlerte;
  String date;
  String unite;
  int code_expl;
  String? imagePath;

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
      id_stock: json['id_stock'],
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