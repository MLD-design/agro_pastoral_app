import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-personnel/modelpaie.dart';

class PaiementService {
  final String baseUrl = "http://192.168.1.200:3000/api/paies";

  // Récupérer la liste des paiements
  Future<List<Paiement>> getByExploitation(int codeExpl, String token) async {
    final res = await http.get(Uri.parse("$baseUrl/$codeExpl"));
    return res.statusCode == 200
        ? (json.decode(res.body) as List).map((e) => Paiement.fromJson(e)).toList()
        : [];
  }

  // Créer un nouveau paiement. Retourne le paiement tel qu'enregistré côté
  // backend (avec son id_paiement réel et ses totaux calculés) — nécessaire
  // pour ensuite générer un bulletin fiable à partir de cet id.
  Future<Paiement> create(Paiement p, String token) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(p.toJson()),
    );

    if (res.statusCode != 201) {
      throw Exception("Échec de la création du paiement");
    }
    return Paiement.fromJson(json.decode(res.body));
  }

  // Mettre à jour le statut
  Future<void> updateStatut(int id, String statut, String token) async {
    await http.put(Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"statut": statut}));
  }

  /// Génère le bulletin à partir du paiement déjà enregistré (id_paiement) :
  /// le backend relit ses propres données stockées, plus fiables que
  /// n'importe quelle valeur renvoyée par le client. entrepriseNom/Adresse
  /// sont optionnels et affichés en en-tête du bulletin.
  Future<String?> generateBulletin(
    Paiement p, {
    String? entrepriseNom,
    String? entrepriseAdresse,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/bulletin"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_paiement": p.id_paiement,
          if (entrepriseNom != null) "entrepriseNom": entrepriseNom,
          if (entrepriseAdresse != null) "entrepriseAdresse": entrepriseAdresse,
        }),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final String relativeUrl = data["url"];
        return "http://192.168.1.200:3000$relativeUrl";
      }
      print("Erreur bulletin (${res.statusCode}): ${res.body}");
      return null;
    } catch (e) {
      print("Erreur service bulletin: $e");
      return null;
    }
  }
}
