import 'package:flutter/material.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-compte/servicesusers.dart';



class CreateUserScreen extends StatefulWidget {
  final User admin;
  CreateUserScreen({required this.admin});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _codeExplCtrl = TextEditingController();

  void _create() async {
    final newUser = await UserService().createUser(
      widget.admin.token,
      _usernameCtrl.text,
      _passwordCtrl.text,
      _roleCtrl.text,
      int.parse(_codeExplCtrl.text),
    );
    if (newUser != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer utilisateur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, decoration: InputDecoration(labelText: "Nom d'utilisateur")),
            TextField(controller: _passwordCtrl, decoration: InputDecoration(labelText: "Mot de passe")),
            TextField(controller: _roleCtrl, decoration: InputDecoration(labelText: "Rôle")),
            TextField(controller: _codeExplCtrl, decoration: InputDecoration(labelText: "Code exploitation")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _create, child: Text("Créer")),
          ],
        ),
      ),
    );
  }
}
