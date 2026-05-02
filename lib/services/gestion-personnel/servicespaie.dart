import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-personnel/modelpaie.dart';

class PaiementService {
  final baseUrl = "http://192.168.1.16:3000/api/paies";

  Future<List<Paiement>> getByExploitation(int codeExpl) async {
    final res = await http.get(Uri.parse("$baseUrl/$codeExpl"));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Paiement.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> create(Paiement paiement) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "employeId": paiement.employeId,
        "code_expl": paiement.code_expl,
        "mois": paiement.mois,
        "annee": paiement.annee,
        "salaireBase": paiement.salaireBase,
        "primes": paiement.primes,
        "retenues": paiement.retenues,
      }),
    );
  }

  Future<void> updateStatut(int idPaiement, String statut) async {
    await http.put(
      Uri.parse("$baseUrl/$idPaiement"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"statut": statut}),
    );
  }

  Future<String?> generateBulletin(Paiement paiement, String employeNom) async {
    final res = await http.post(
      Uri.parse("$baseUrl/bulletin"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "employeNom": employeNom,
        "mois": paiement.mois,
        "annee": paiement.annee,
        "salaireBase": paiement.salaireBase,
        "primes": paiement.primes,
        "retenues": paiement.retenues,
        "net": paiement.net,
      }),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data["url"];
    }
    return null;
  }
}
