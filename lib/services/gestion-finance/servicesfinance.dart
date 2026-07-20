import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanceService {
  static const baseUrl = "http://192.168.1.200:3000/api/finance";

  static Future addDepense(Map data) async {
    await http.post(
      Uri.parse("$baseUrl/depenses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future addRecette(Map data) async {
    await http.post(
      Uri.parse("$baseUrl/recettes"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<List> getDepenses(int codeExpl) async {
    final res =
    await http.get(Uri.parse("$baseUrl/depenses/$codeExpl"));
    return jsonDecode(res.body);
  }

  static Future<List> getRecettes(int codeExpl, ) async {
    final res =
    await http.get(Uri.parse("$baseUrl/recettes/$codeExpl"));
    return jsonDecode(res.body);
  }

  static Future<Map> getRentabilite(int codeExpl, ) async {
    final res =
    await http.get(Uri.parse("$baseUrl/rentabilite/$codeExpl"));
    return jsonDecode(res.body);
  }
}