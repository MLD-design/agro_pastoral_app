import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-culture/modelcampagne.dart';

class CampagneService {
  final String baseUrl =
      "http://192.168.1.16:3000/api/campagnes";

  Future<List<Campagne>> getByParcelle(int id_cham) async {
    final res = await http.get(
      Uri.parse("$baseUrl/parcelle/$id_cham"),
    );

    List data = jsonDecode(res.body);
    return data.map((e) {
      print("ITEM=$e");
      return Campagne.fromJson(e);
    }).toList();
  }

  Future<void> create(Campagne camp) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(camp.toJson()),
    );
  }
}