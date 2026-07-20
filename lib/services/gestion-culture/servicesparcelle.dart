import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-culture/modelparcelle.dart';

class ParcelleService {
  final String baseUrl = "http://192.168.1.200:3000/api/parcelles";

  // 🔹 GET ALL (optionnel)
  Future<List<Parcelle>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    List data = jsonDecode(res.body);
    return data.map((e) => Parcelle.fromJson(e)).toList();
  }

  // ✅ 🔥 GET PAR EXPLOITATION
  Future<List<Parcelle>> getByExploitation(int code_expl, String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/exploitation/$code_expl"),
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Parcelle.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement parcelles");
    }
  }

  // ➕ AJOUT
  Future<void> add(Parcelle parcelle, String token) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(parcelle.toJson()),
    );
  }

  // ❌ DELETE
  Future<void> delete(int id_cham, String token) async {
    await http.delete(Uri.parse("$baseUrl/$id_cham"));
  }

  // ✏️ UPDATE
  Future<void> update(int id_cham, Parcelle parcelle, String token) async {
    await http.put(
      Uri.parse("$baseUrl/$id_cham"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(parcelle.toJson()),
    );
  }
}