import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../models/gestion-compte/modeluser.dart';
// Importe tes pages ici
import 'Personnel.dart';
import '../gestion-alerte/alerte.dart'; // Ta page d'alerte modifiée précédemment
// Importe ta page de rapports/stats si elle existe

class GestionnaireDashboard extends StatefulWidget {
  final User user;
  const GestionnaireDashboard({super.key, required this.user});

  @override
  State<GestionnaireDashboard> createState() => _GestionnaireDashboardState();
}

class _GestionnaireDashboardState extends State<GestionnaireDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B4332),
        title: const Text("FARMFLOW MANAGEMENT",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text(widget.user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 15),
        ],
      ),
      drawer: _buildDrawer(context), // Barre de navigation latérale
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 25),
            const Text("Aperçu Rapide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            const SizedBox(height: 15),
            _buildQuickStats(),
            const SizedBox(height: 25),
            const Text("Actions Principales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            const SizedBox(height: 15),
            _buildActionGrid(context),
          ],
        ),
      ),
    );
  }

  // --- HEADER DE BIENVENUE ---
  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bonjour, ${widget.user.username} 👋",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Voici l'état actuel de votre exploitation aujourd'hui.",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  // --- STATISTIQUES RAPIDES ---
  Widget _buildQuickStats() {
    return Row(
      children: [
        _smallStatCard("Personnel", "12", Icons.people, Colors.blue),
        const SizedBox(width: 15),
        _smallStatCard("Alertes", "3", Icons.warning_amber_rounded, Colors.orange),
      ],
    );
  }

  Widget _smallStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- GRILLE D'ACTIONS (Navigation vers les 3 fonctionnalités) ---
  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _actionCard(
          context,
          "Personnel",
          "Gérer vos équipes",
          FontAwesomeIcons.usersGear,
          Colors.indigo,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => PersonnelPage(user: widget.user))),
        ),
        _actionCard(
          context,
          "Alertes",
          "Monitoring Live",
          FontAwesomeIcons.warning,
          Colors.redAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertePage(user: widget.user))),
        ),
        _actionCard(
          context,
          "Statistiques",
          "Rapports & Data",
          FontAwesomeIcons.chartPie,
          Colors.teal,
              () { /* Navigation vers StatsPage */ },
        ),
        _actionCard(
          context,
          "Paramètres",
          "Configuration",
          FontAwesomeIcons.gears,
          Colors.blueGrey,
              () { /* Navigation vers Paramètres */ },
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.1), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // --- MENU DE NAVIGATION LATÉRAL (DRAWER) ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF0F4F2),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1B4332)),
              accountName: Text(widget.user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text("Gestionnaire - Code: ${widget.user.code_expl}"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(widget.user.username[0], style: const TextStyle(fontSize: 30, color: Color(0xFF1B4332))),
              ),
            ),
            _drawerItem(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context)),
            _drawerItem(Icons.people_alt_rounded, "Gestion Personnel", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => PersonnelPage(user: widget.user)));
            }),
            _drawerItem(Icons.notification_important_rounded, "Alertes & Monitoring", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => AlertePage(user: widget.user)));
            }),
            _drawerItem(Icons.bar_chart_rounded, "Rapports & Stats", () {
              Navigator.pop(context);
              // Navigation stats
            }),
            const Spacer(),
            const Divider(),
            _drawerItem(Icons.logout_rounded, "Déconnexion", () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false), color: Colors.red),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color color = const Color(0xFF1B4332)}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}