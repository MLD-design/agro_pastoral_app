import 'dart:convert';
import 'package:http/http.dart' as http;

class SuiviService {
  final baseUrl = "http://192.168.1.16:3000/api/suivi";

  Future<Map<String, dynamic>> get(
      String exp, String parc, String camp) async {

    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      "code_expl": exp,
      "id_cham": parc,
      "id_camp": camp,
    });

    final res = await http.get(uri);

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 || body['success'] == false) {
      throw Exception(body['message'] ?? "Erreur serveur");
    }

    return body['data'];
  }

  Future<void> create(
      String exp, String parc, String camp) async {

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code_expl": exp,
        "id_cham": parc,
        "id_camp": camp,
      }),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 || body['success'] == false) {
      throw Exception(body['message']);
    }
  }

  Future<String?> update(
      String exp,
      String parc,
      String camp,
      String type,
      int index) async {

    final res = await http.post(
      Uri.parse("$baseUrl/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code_expl": exp,
        "id_cham": parc,
        "id_camp": camp,
        "type": type,
        "index": index
      }),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 || body['success'] == false) {
      return body['message'];
    }

    return null;
  }
}