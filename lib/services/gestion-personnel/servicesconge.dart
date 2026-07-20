import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-personnel/modelconge.dart';

class CongeService {
  final baseUrl = "http://192.168.1.200:3000/api/conges";

  Future<List<Conge>> getByExploitation(int codeExpl, String token) async {
    final res = await http.get(Uri.parse("$baseUrl/$codeExpl"));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Conge.fromJson(e)).toList();
    }
    return [];
  }

  // 🔴 NOUVELLE MÉTHODE : Récupérer les congés d'un employé spécifique
  Future<List<Conge>> getByEmploye(int employeId, String token) async {
    final res = await http.get(Uri.parse("$baseUrl/employe/$employeId"));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Conge.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> add(Conge conge, String token) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "employeId": conge.employeId,
        "type": conge.type,
        "dateDebut": conge.dateDebut,
        "dateFin": conge.dateFin,
        "code_expl": conge.code_expl,
      }),
    );
  }

  Future<void> updateStatut(int idConge, String statut, String token) async {
    await http.put(
      Uri.parse("$baseUrl/$idConge"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"statut": statut}),
    );
  }
}