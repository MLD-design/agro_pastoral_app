import 'package:flutter/material.dart';
import 'dart:ui'; // Pour l'effet de flou (Glassmorphism)
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tes imports existants
import '../gestion-activitéagro/activitéAgro.dart';
import '../../services/gestion-compte/servicesauth.dart';
import '../gestion-soinscheptel/soinscheptel.dart';
import '../gestion-cheptel/gestion_cheptel.dart';
import '../gestion-culture/vugestion_cultures.dart';
import '../gestion-finance/vugestion_finances.dart';
import '../gestion-personnel/gestionnairedash.dart';
import '../gestion-stock/vugestion_stock.dart';
import 'AdminScreen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _isObscure = true;

  void _login() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = "Veuillez remplir tous les champs");
      return;
    }

    setState(() { _loading = true; _error = null; });
    final user = await AuthService().login(_usernameCtrl.text, _passwordCtrl.text);
    setState(() { _loading = false; });

    if (user != null) {
      // Ta logique de redirection reste la même
      Widget nextPage;
      switch (user.role) {
        case "admin": nextPage = AdminScreen(user: user); break;
        case "gestionnaire_stock": nextPage = StockPage(user: user); break;
        case "technicien_agricole": nextPage = MyCulturePage(user: user, code_expl: user.code_expl); break;
        case "technicien_elevage": nextPage = MyCheptelePage(user: user, title: ''); break;
        case "comptable": nextPage = FinancePage(user: user); break;
        case "gestionnaire": nextPage = GestionnaireDashboard(user: user); break;
        case "ingénieur_agronome": nextPage = ActivityagroPage(user: user, title: ''); break;
        case "veterinaire": nextPage = SoinscheptelPage(user: user, title: ''); break;
        default:
          setState(() => _error = "Rôle non reconnu");
          return;
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextPage));
    } else {
      setState(() => _error = "Identifiants invalides");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B4332), // Vert forêt (Logo)
              Color(0xFF2D6A4F), // Vert moyen
              Color(0xFF74C69D), // Vert tendre
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 80),
                // Section Logo/Nom
                _buildHeader(),
                SizedBox(height: 50),
                // Formulaire Glassmorphism
                _buildLoginForm(),
                SizedBox(height: 30),
                if (_error != null)
                  _buildError(context),
                SizedBox(height: 20),
                _buildLoginButton(),
                SizedBox(height: 50),
                Text(
                  "© 2026 Chiifahi FarmFlow - Excellence Agricole",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(FontAwesomeIcons.leaf, color: Color(0xFFD8F3DC), size: 50),
        ),
        SizedBox(height: 20),
        Text(
          "CHIIFAHI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        Text(
          "FARMFLOW",
          style: TextStyle(
            color: Color(0xFFB7E4C7),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildTextField(
                controller: _usernameCtrl,
                hint: "Identifiant",
                icon: Icons.person_outline,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordCtrl,
                hint: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Color(0xFFB7E4C7)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF74C69D)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD8F3DC),
          foregroundColor: Color(0xFF1B4332),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: _loading
            ? CircularProgressIndicator(color: Color(0xFF1B4332))
            : Text(
          "SE CONNECTER",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _error!,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}