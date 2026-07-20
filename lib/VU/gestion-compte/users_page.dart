import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-compte/servicesusers.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';

class CreateUserScreen extends StatefulWidget {
  final User admin;
  final Personnel personnelTarget;

  const CreateUserScreen({
    super.key,
    required this.admin,
    required this.personnelTarget
  });

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final ExploitationService _exploitationService = ExploitationService();

  int? _selectedExploitationId;
  String? _selectedRole;
  bool _isObscure = true;
  bool _isLoadingExpl = true;

  List<Exploitation> _myExploitations = [];

  // Liste des rôles autorisés (en minuscules pour correspondre aux valeurs de sélection)
  final List<String> roles = [
    "admin", "gestionnaire_stock", "technicien_agricole",
    "technicien_elevage", "comptable", "gestionnaire",
    "ingenieur_agronome", "veterinaire"
  ];

  @override
  void initState() {
    super.initState();
    _fetchMyExploitations();

    // 🔴 1. SÉCURISATION DU RÔLE (Évite le crash sur le Dropdown Rôle)
    // On nettoie la chaîne reçue (minuscules et suppression des espaces superflus)
    String? targetPoste = widget.personnelTarget.poste.toLowerCase().trim();

    // On vérifie si ce rôle existe à l'identique dans notre liste autorisée
    if (roles.contains(targetPoste)) {
      _selectedRole = targetPoste;
    } else {
      // Si c'est un compte libre ou un poste inconnu, on laisse null (sélection manuelle requise)
      _selectedRole = null;
    }

    // 🔴 2. SÉCURISATION DE L'EXPLOITATION (Évite le crash sur la valeur 0)
    if (widget.personnelTarget.code_expl == 0) {
      _selectedExploitationId = null;
    } else {
      _selectedExploitationId = widget.personnelTarget.code_expl;
    }

    // Génération automatique du nom d'utilisateur uniquement pour un vrai personnel
    if (widget.personnelTarget.code_per != 0) {
      _usernameCtrl.text = widget.personnelTarget.nom.toLowerCase().replaceAll(' ', '_');
    }
  }

  void _fetchMyExploitations() async {
    try {
      final List<Exploitation> data = await _exploitationService.getAll();
      setState(() {
        _myExploitations = data;
        _isLoadingExpl = false;
      });
    } catch (e) {
      setState(() => _isLoadingExpl = false);
      debugPrint("Erreur lors du chargement des exploitations : $e");
    }
  }

  void _create() async {
    if (_selectedRole == null || _selectedExploitationId == null || _usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    final newUser = await UserService().createUser(
      widget.admin.token,
      _usernameCtrl.text,
      _passwordCtrl.text,
      _selectedRole!,
      _selectedExploitationId!,
      widget.personnelTarget.code_per,
    );

    if (newUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès !")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création du compte")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white)
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF081C15), Color(0xFF1B4332), Color(0xFF2D6A4F)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 100),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildGlassForm(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isLibre = widget.personnelTarget.code_per == 0;
    return Column(
      children: [
        const Icon(FontAwesomeIcons.userShield, color: Colors.white, size: 50),
        const SizedBox(height: 20),
        Text(
          isLibre ? "Nouveau Compte Libre" : "Compte pour : ${widget.personnelTarget.nom}",
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGlassForm() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildTextField(_usernameCtrl, "Nom d'utilisateur", Icons.person_outline),
          const SizedBox(height: 20),
          _buildTextField(_passwordCtrl, "Mot de passe", Icons.lock_outline, isPassword: true),
          const SizedBox(height: 20),
          _buildRoleDropdown(),
          const SizedBox(height: 20),
          _buildExploitationDropdown(),
        ],
      ),
    );
  }

  Widget _buildExploitationDropdown() {
    return _isLoadingExpl
        ? const LinearProgressIndicator(color: Color(0xFF95D5B2), backgroundColor: Colors.transparent)
        : DropdownButtonFormField<int>(
      value: _selectedExploitationId,
      dropdownColor: const Color(0xFF1B4332),
      style: const TextStyle(color: Colors.white),
      items: _myExploitations.map((exp) => DropdownMenuItem<int>(
          value: exp.code_expl,
          child: Text(exp.nom_expl, style: const TextStyle(fontSize: 13))
      )).toList(),
      onChanged: (val) => setState(() => _selectedExploitationId = val),
      decoration: InputDecoration(
        labelText: "Affecter à l'exploitation",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.agriculture, color: Color(0xFF95D5B2), size: 20),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF95D5B2)),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ) : null,
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      dropdownColor: const Color(0xFF1B4332),
      style: const TextStyle(color: Colors.white),
      items: roles.map((r) => DropdownMenuItem(
          value: r,
          child: Text(r.toUpperCase().replaceAll('_', ' '), style: const TextStyle(fontSize: 13))
      )).toList(),
      onChanged: (val) => setState(() => _selectedRole = val),
      decoration: InputDecoration(
        labelText: "Rôle",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.assignment_ind_outlined, color: Color(0xFF95D5B2)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _create,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF74C69D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text("CRÉER LE COMPTE", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF081C15))),
      ),
    );
  }
}