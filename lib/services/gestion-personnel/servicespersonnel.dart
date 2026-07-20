import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-personnel/modelpersonnel.dart';

class PersonnelService {
  final String base = "http://192.168.1.200:3000/api/personnels";

  Future<List<Personnel>> getAll() async {
    final res = await http.get(Uri.parse(base));

    List data = jsonDecode(res.body);

    return data.map((e) => Personnel.fromJson(e)).toList();
  }


  Future<List<Personnel>> getByExploitation(int code_expl, String token) async {

    final res = await http.get(Uri.parse("$base/exploitation/$code_expl")).timeout(Duration(seconds: 5));


    if (res.statusCode != 200) throw Exception("Erreur");

    final data = jsonDecode(res.body) as List;

    return data.map((e) => Personnel.fromJson(e)).toList();
  }

  Future<void> add(Personnel p, String token) async {
    await http.post(
      Uri.parse(base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nom": p.nom,
        "poste": p.poste,
        "salaire": p.salaire,
        "code_expl": p.code_expl,
      }),
    );
  }




}