import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/gestion-personnel/modelcontrat.dart';

class ContratService {
  final String base = "http://192.168.1.200:3000/api/contrats";

  Future<void> create(Contrat c, File file, String token) async {
    var request = http.MultipartRequest('POST', Uri.parse(base));
    request.fields['employeId'] = c.employeId.toString();
    request.fields['type'] = c.type;
    request.fields['dateDebut'] = c.dateDebut;
    request.fields['dateFin'] = c.dateFin;
    request.fields['code_expl'] = c.code_expl.toString();

    request.files.add(await http.MultipartFile.fromPath("contrat", file.path));
    await request.send();
  }

  Future<List<Contrat>> getAll() async {
    final res = await http.get(Uri.parse(base));
    final data = jsonDecode(res.body);
    return data.map<Contrat>((e) => Contrat.fromJson(e)).toList();
  }

  Future<List<Contrat>> getByExploitation(int codeExpl, String token) async {
    final res = await http.get(Uri.parse("$base/$codeExpl"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data.map<Contrat>((e) => Contrat.fromJson(e)).toList();
    }
    return [];
  }
}
