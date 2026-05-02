import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gestion-compte/modeluser.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.42:3000/api/auth";

  Future<User?> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    }
    return null;
  }
}
