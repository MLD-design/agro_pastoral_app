import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/gestion-cheptel/modelanimal.dart';
import '/models/gestion-cheptel/modelreproduction.dart';
import '/models/gestion-cheptel/modelproduction.dart';
import '/models/gestion-cheptel/modelmouvement.dart';

class CheptelService {
  final String baseUrl = "http://192.168.1.200:3000/s/api/cheptel";

  // ---------------- Animaux ----------------
  Future<List<Animal>> getAnimaux(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl/animaux"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Animal.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement animaux");
    }
  }

  Future<void> enregistrerAnimal(int codeExpl, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$codeExpl/animaux"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Erreur enregistrement animal");
    }
  }

  // ---------------- Reproduction ----------------
  Future<List<Reproduction>> getReproductions(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl/reproduction"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reproduction.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement reproductions");
    }
  }

  Future<void> enregistrerReproduction(int codeExpl, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$codeExpl/reproduction"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Erreur enregistrement reproduction");
    }
  }

  // ---------------- Production ----------------
  Future<List<Production>> getProductions(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl/production"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Production.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement productions");
    }
  }

  Future<void> enregistrerProduction(int codeExpl, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$codeExpl/production"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Erreur enregistrement production");
    }
  }

  // ---------------- Mouvements ----------------
  Future<List<Mouvement>> getMouvements(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl/mouvements"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mouvement.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement mouvements");
    }
  }

  Future<void> enregistrerMouvement(int codeExpl, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$codeExpl/mouvements"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Erreur enregistrement mouvement");
    }
  }

  // ---------------- Rapport ----------------
  Future<Map<String, dynamic>> getRapport(int codeExpl) async {
    final response = await http.get(Uri.parse("$baseUrl/$codeExpl/rapport"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur chargement rapport");
    }
  }
}
