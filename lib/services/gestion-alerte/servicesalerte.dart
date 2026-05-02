import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/gestion-alerte/modelalerte.dart';

class AlerteService {
  final String baseUrl = "http://192.168.1.16:3000/api/alertes";

  Future<List<Alerte>> getByExploitation(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Alerte.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des alertes");
    }
  }

  Future<void> traiter(int id) async {
    await http.put(Uri.parse("$baseUrl/$id"));
  }

  Future<void> archiver(int id) async {
    await http.put(Uri.parse("$baseUrl/$id/archive"));
  }
}
