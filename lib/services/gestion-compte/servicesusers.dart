import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-compte/modeluser.dart';

class UserService {
  final String baseUrl = "http://192.168.1.200:3000/api/users";

  // ✅ CREATE : Mis à jour avec le personnelId pour la liaison
  Future<User?> createUser(
      String token,
      String username,
      String password,
      String role,
      int codeExpl,
      int personnelId // 🔴 On ajoute le code_per du personnel à lier
      ) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "role": role,
          "code_expl": codeExpl,
          "personnelId": personnelId // 🔴 Transmis au backend Node.js
        }),
      );

      // Ton backend renvoie un statut 201 lors d'un succès
      if (res.statusCode == 201 || res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);

        // Si ton backend renvoie { message: "...", user: {...} }, on extrait la clé "user"
        if (responseData.containsKey('user')) {
          return User.fromJson(responseData['user']);
        }
        return User.fromJson(responseData);
      }

      print("Erreur API de création: ${res.body}");
      return null;
    } catch (e) {
      print("Erreur connexion createUser: $e");
      return null;
    }
  }

  // ✅ UPDATE
  Future<User?> updateUser(String token, int id, {String? username, String? password, String? role, int? codeExpl}) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"username": username, "password": password, "role": role, "code_expl": codeExpl}),
      );
      if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
      return null;
    } catch (e) {
      print("Erreur connexion updateUser: $e");
      return null;
    }
  }

  // ✅ DELETE
  Future<bool> deleteUser(String token, int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"), headers: {"Authorization": "Bearer $token"});
      return res.statusCode == 200;
    } catch (e) {
      print("Erreur connexion deleteUser: $e");
      return false;
    }
  }

  // ✅ GET ALL
  Future<List<User>> listUsers(String token) async {
    try {
      final res = await http.get(Uri.parse(baseUrl), headers: {"Authorization": "Bearer $token"});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((u) => User.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur connexion listUsers: $e");
      return [];
    }
  }
}