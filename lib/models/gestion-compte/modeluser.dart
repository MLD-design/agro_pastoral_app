class User {
  final int id;
  final String username;
  final String role;
  final int code_expl;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.code_expl,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] ?? 0, // ✅ valeur par défaut
      username: json["username"] ?? "",
      role: json["role"] ?? "",
      code_expl: json["code_expl"] ?? 0, // ✅ valeur par défaut
      token: json["token"] ?? "",
    );
  }
}
