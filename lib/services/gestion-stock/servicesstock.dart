import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-stock/modelstock.dart';

class StockService {
  static const baseUrl = "http://192.168.1.200:3000/api/stock";

  // ✅ Récupérer tous les stocks
  static Future<List<Stock>> getStocks(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ ajout du token
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body.map((e) => Stock.fromJson(e)).toList();
      }
      throw Exception("Format inattendu pour getStocks");
    } else {
      throw Exception("Erreur lors du chargement des stocks");
    }
  }

  // ✅ Récupérer les stocks par exploitation
  static Future<List<Stock>> getStocksByExpl(int code_expl, String token) async {
    print("TOKEN ENVOYE=$token");
    final res = await http.get(
      Uri.parse("$baseUrl/expl/$code_expl"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ ajout du token
      },
    );
    print("REPONSE=${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body.map((e) => Stock.fromJson(e)).toList();
      }
      if (body is Map && body.containsKey("stocks")) {
        final List<dynamic> data = body["stocks"];
        return data.map((e) => Stock.fromJson(e)).toList();
      }
      throw Exception("Format inattendu pour getStocksByExpl");
    } else {
      throw Exception("Erreur lors du chargement des stocks par exploitation");
    }
  }

  // ✅ Ajouter un stock
  static Future<void> addStock(Map<String, dynamic> data, String token) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ ajout du token
      },
      body: jsonEncode(data),
    );

    // ✅ Accepter 200 (OK) et 201 (Created)
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Erreur lors de l'ajout du stock");
    }
  }

  // ✅ Entrée de stock
  static Future<void> entree(String id_stock, int quantite, String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/entree/$id_stock"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ ajout du token
      },
      body: jsonEncode({"quantite": quantite}),
    );

    if (res.statusCode != 200) {
      throw Exception("Erreur lors de l'entrée du stock");
    }
  }

  // ✅ Sortie de stock
  static Future<void> sortie(String id_stock, int quantite, String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/sortie/$id_stock"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ ajout du token
      },
      body: jsonEncode({"quantite": quantite}),
    );

    if (res.statusCode != 200) {
      throw Exception("Erreur lors de la sortie du stock");
    }
  }
}
