import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/gestion-stock/modelstock.dart';


class StockService {

  static const baseUrl = "http://192.168.1.16:3000/api/stock";

  static Future<List<Stock>> getStocks() async {

    final res = await http.get(Uri.parse(baseUrl));

    final data = jsonDecode(res.body);

    return List<Stock>.from(data.map((e) => Stock.fromJson(e)));

  }
  static Future<List<Stock>> getStocksByExpl(int code_expl) async {
    final res = await http.get(
      Uri.parse("$baseUrl/expl/$code_expl"),
    );

    final data = jsonDecode(res.body);
    return List<Stock>.from(data.map((e) => Stock.fromJson(e)));
  }

  static Future<void> addStock(Map data) async {

    await http.post(Uri.parse(baseUrl),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode(data));

  }

  static Future<void> entree(String id_stock, int quantite) async {

    await http.post(Uri.parse("$baseUrl/entree/$id_stock"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"quantite": quantite}));

  }

  static Future<void> sortie(String id_stock, int quantite) async {

    await http.post(Uri.parse("$baseUrl/sortie/$id_stock"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"quantite": quantite}));

  }


}