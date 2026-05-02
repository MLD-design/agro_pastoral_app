import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-compte/modeluser.dart';


class UserService {
  final String baseUrl = "http://192.168.1.42:3000/api/users";

  Future<User?> createUser(String token, String username, String password, String role, int codeExpl) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"username": username, "password": password, "role": role, "code_expl": codeExpl}),
    );
    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    return null;
  }

  Future<User?> updateUser(String token, int id, {String? username, String? password, String? role, int? codeExpl}) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"username": username, "password": password, "role": role, "code_expl": codeExpl}),
    );
    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    return null;
  }

  Future<bool> deleteUser(String token, int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"), headers: {"Authorization": "Bearer $token"});
    return res.statusCode == 200;
  }

  Future<List<User>> listUsers(String token) async {
    final res = await http.get(Uri.parse(baseUrl), headers: {"Authorization": "Bearer $token"});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((u) => User.fromJson(u)).toList();
    }
    return [];
  }
}
