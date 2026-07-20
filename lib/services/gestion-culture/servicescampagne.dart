import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-culture/modelcampagne.dart';

class CampagneService {
  // URL de votre API ExpressJS (pensez à vérifier que votre PC/serveur utilise bien cette IP)
  final String baseUrl = "http://192.168.1.200:3000/api/campagnes";

  // 1. RÉCUPÉRER LES CAMPAGNES D'UNE PARCELLE (Avec couleur d'alerte incluse)
  Future<List<Campagne>> getByParcelle(int id_cham, String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/parcelle/$id_cham"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Prise en compte du token de sécurité
      },
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      print("ERREUR SERVEUR : ${res.statusCode} - ${res.body}");

      return data.map((e) {
        print("CAMPAGNE REÇUE = $e"); // Utile pour vérifier l'injection de "status_couleur"
        return Campagne.fromJson(e);
      }).toList();
    } else {
      throw Exception("Erreur lors de la récupération des campagnes (Code: ${res.statusCode})");
    }
  }

  // 1bis. RÉCUPÉRER TOUTES LES CAMPAGNES DE L'EXPLOITATION (toutes parcelles confondues)
  Future<List<Campagne>> getByExploitation(int code_expl, String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/exploitation/$code_expl"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Campagne.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des campagnes (Code: ${res.statusCode})");
    }
  }

  // 2. CRÉER UNE CAMPAGNE PLANIFIÉE
  // Ne déclenche plus le suivi côté backend (module désormais indépendant,
  // voir SuiviService.create) — on retourne la campagne créée pour récupérer
  // son id_camp généré par le backend et pouvoir initialiser son suivi ensuite.
  Future<Campagne> create(Campagne camp, String token) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(camp.toJson()),
    );

    if (res.statusCode != 201) {
      throw Exception("Échec de la création de la campagne planifiée");
    }

    final body = jsonDecode(res.body);
    return Campagne.fromJson(body['data']);
  }

  // 3. ENREGISTRER L'AVANCEMENT DE LA FRISE GLOBALE (Ajouté)
  // Permet de mettre à jour l'étape et d'envoyer la quantité récoltée en fin de cycle
  Future<void> updateEtape(int idCamp, String etapeActuelle, double quantiteRecoltee, String token) async {
    final res = await http.put(
      Uri.parse("$baseUrl/update-etape/$idCamp"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "etape_actuelle": etapeActuelle,       // 'Semis', 'Traitement' ou 'Récoltée'
        "quantite_recoltee": quantiteRecoltee  // Poids récolté en kg (0 par défaut)
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Impossible de mettre à jour la phase de la campagne");
    }
  }
}