// lib/services/gestion-culture/servicessuivi.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuiviService {
  final String baseUrl = "http://192.168.1.200:3000/api/suivi";

  // 🔗 Initialise le suivi d'une campagne déjà planifiée. Le backend vérifie
  // lui-même qu'une campagne existe pour cette exploitation/parcelle/campagne
  // avant de créer le suivi (404 sinon). Si le suivi existe déjà, le backend
  // renvoie 200 avec les données existantes — donc cet appel est idempotent
  // et peut être fait sans risque à chaque fois qu'on ouvre SuiviPage.
  Future<Map<String, dynamic>> create(String idCham, String idCamp, String token, {String? dateFin}) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id_cham": idCham,
        "id_camp": idCamp,
        if (dateFin != null) "date_fin": dateFin,
      }),
    );

    final body = jsonDecode(res.body);
    if ((res.statusCode != 201 && res.statusCode != 200) || body['success'] == false) {
      throw Exception(body['message'] ?? "Impossible d'initialiser le suivi");
    }
    return body['data'];
  }

  Future<Map<String, dynamic>> get(String idCham, String idCamp, String token) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      "id_cham": idCham,
      "id_camp": idCamp,
    });

    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['success'] == false) {
      throw Exception(body['message'] ?? "Erreur serveur");
    }
    return body['data'];
  }

  // Valide un jalon de la phase semis : "semis" ou "levee"
  Future<String?> validerEtape(String idCham, String idCamp, String type,
      Map<String, dynamic>? formData, String token) async {
    final res = await http.put(
      Uri.parse("$baseUrl/update"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"id_cham": idCham, "id_camp": idCamp, "type": type, "formData": formData}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['success'] == false) {
      return body['message'] ?? "Erreur lors de la validation";
    }
    return null;
  }

  // Ajoute une observation de croissance pendant la phase semis
  Future<String?> ajouterObservation(String idCham, String idCamp, String note,
      Map<String, dynamic>? formData, String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/observation"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({
        "id_cham": idCham, "id_camp": idCamp,
        "note": note, "formData": formData,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201 || body['success'] == false) {
      return body['message'] ?? "Erreur lors de l'ajout de l'observation";
    }
    return null;
  }

  // Enregistre un passage de récolte (quantité, unité, qualité...)
  Future<String?> ajouterPassageRecolte(String idCham, String idCamp, double quantite,
      String unite, String? qualite, String? note, String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/recolte"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({
        "id_cham": idCham, "id_camp": idCamp,
        "quantite": quantite, "unite": unite, "qualite": qualite, "note": note,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201 || body['success'] == false) {
      return body['message'] ?? "Erreur lors de l'enregistrement de la récolte";
    }
    return null;
  }

  // Clôture la phase récolte (au moins un passage requis)
  Future<String?> cloturerRecolte(String idCham, String idCamp, String token) async {
    final res = await http.put(
      Uri.parse("$baseUrl/recolte/cloturer"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"id_cham": idCham, "id_camp": idCamp}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['success'] == false) {
      return body['message'] ?? "Erreur lors de la clôture de la récolte";
    }
    return null;
  }

  Future<String?> ajouterTraitement(String idCham, String idCamp, String description,
      String phase, Map<String, dynamic>? formData, String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/traitement"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({
        "id_cham": idCham, "id_camp": idCamp,
        "description": description, "phase": phase, "formData": formData,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201 || body['success'] == false) {
      return body['message'] ?? "Erreur lors de l'ajout du traitement";
    }
    return null;
  }
}
