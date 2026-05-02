import 'package:flutter/material.dart';
import '../../activitéAgro.dart';
import '../../services/gestion-compte/servicesauth.dart';

import '../../soinscheptel.dart';
import '../gestion-cheptel/gestion_cheptel.dart';
import '../gestion-culture/vugestion_cultures.dart';
import '../gestion-finance/vugestion_finances.dart';
import '../gestion-personnel/Personnel.dart';
import '../gestion-stock/vugestion_stock.dart';
import 'AdminScreen.dart';
import '../../models/gestion-compte/modeluser.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() { _loading = true; _error = null; });
    final user = await AuthService().login(_usernameCtrl.text, _passwordCtrl.text);
    setState(() { _loading = false; });

    if (user != null) {
      if (user.role == "admin") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminScreen(user: user)));
      } else if (user.role == "gestionnaire_stock") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StockPage(user: user )));
      } else if (user.role == "technicien_agricole") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyCulturePage(user: user, code_expl: user.code_expl)));
      } else if (user.role == "technicien_elevage") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyCheptelePage(user: user, title: '',)));
      } else if (user.role == "comptable") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FinancePage(user: user)));
      } else if (user.role == "gestionnaire") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PersonnelPage(user: user)));
      } else if (user.role == "ingénieur_agronome") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ActivityagroPage(user: user, title: '',)));
      } else if (user.role == "véterinaire") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SoinscheptelPage(user: user, title: '',)));

      } else {
        setState(() { _error = "Rôle non reconnu"; });
      }
    } else {
      setState(() { _error = "Identifiants invalides"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, decoration: InputDecoration(labelText: "Nom d'utilisateur")),
            TextField(controller: _passwordCtrl, decoration: InputDecoration(labelText: "Mot de passe"), obscureText: true),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _login, child: Text("Se connecter")),
          ],
        ),
      ),
    );
  }
}
