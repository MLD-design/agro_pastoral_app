// lib/services/gestion-culture/servicesrapport.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-culture/modelrapport.dart';

class RapportService {
  final String baseUrl = "http://192.168.1.200:3000/api/rapport";

  // Le code_expl est déduit du token côté serveur : on ne l'envoie plus dans l'URL.
  Future<RapportCulture> getRapport(int idCham, int idCamp, String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/$idCham/$idCamp"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['success'] == false) {
      throw Exception(body['message'] ?? "Impossible de générer le bilan pour cette campagne");
    }
    return RapportCulture.fromJson(body['data']);
  }
}
