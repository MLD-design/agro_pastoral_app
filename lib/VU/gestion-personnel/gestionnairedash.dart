import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../models/gestion-compte/modeluser.dart';
import '../../../providers/selectedexploitationprovider.dart';
import '../../services/gestion-alerte/servicesalerte.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';
import 'Personnel.dart';
import '../gestion-alerte/alerte.dart';

class GestionnaireDashboard extends StatefulWidget {
  final User user;
  const GestionnaireDashboard({super.key, required this.user});

  @override
  State<GestionnaireDashboard> createState() => _GestionnaireDashboardState();
}

class _GestionnaireDashboardState extends State<GestionnaireDashboard> {
  final exploitationService = ExploitationService();
  final personnelService = PersonnelService();
  final alerteService = AlerteService();

  String nomExploitation = "";
  int nbPersonnel = 0;
  int nbAlertes = 0;
  bool isLoading = true;
  int? _lastCheckedExploitationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final providerExp = Provider.of<SelectedExploitationProvider>(context).exploitation;
    final int? targetCodeExpl = providerExp?.code_expl ?? widget.user.code_expl;

    if (targetCodeExpl != null && _lastCheckedExploitationId != targetCodeExpl) {
      _lastCheckedExploitationId = targetCodeExpl;

      if (providerExp != null) {
        setState(() => nomExploitation = providerExp.nom_expl);
      }

      _loadDashboardData(targetCodeExpl);
    }
  }

  Future<void> _loadDashboardData(int codeExpl) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      if (nomExploitation == "Chargement...") {
        final domaines = await exploitationService.getAll();
        final exploitationActuelle = domaines.firstWhere(
              (e) => e.code_expl == codeExpl,
          orElse: () => domaines.first,
        );
        if (mounted) {
          setState(() => nomExploitation = exploitationActuelle.nom_expl);
        }
      }

      final mutualData = await Future.wait([
        personnelService.getByExploitation(codeExpl, widget.user.token),
        alerteService.getByExploitation(codeExpl),
      ]);

      if (mounted) {
        setState(() {
          nbPersonnel = (mutualData[0] as List).length;
          nbAlertes = (mutualData[1] as List).length;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🔴 ERREUR DASHBOARD API : $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          if (nomExploitation == "Chargement...") {
            nomExploitation = "Exploitation Spécifiée";
          }
        });
      }
    }
  }

  // --- LOGIQUE DE DÉCONNEXION RÉINTEGRÉE ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Déconnexion"),
          ],
        ),
        content: const Text("Voulez-vous vraiment quitter l'application ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Nettoie l'historique de navigation et redirige vers l'authentification
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("DÉCONNEXION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerExp = Provider.of<SelectedExploitationProvider>(context).exploitation;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          "FARMFLOW MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // 🔴 BOUTON DÉCONNEXION PLACÉ À GAUCHE DE L'AVATAR
          IconButton(
            tooltip: "Se déconnecter",
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 22),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text(
              widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : "U",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B4332),
        onRefresh: () async {
          final int? activeCode = providerExp?.code_expl ?? widget.user.code_expl;
          if (activeCode != null) {
            await _loadDashboardData(activeCode);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(nomExploitation),
              const SizedBox(height: 25),
              const Text("Aperçu Rapide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
              const SizedBox(height: 15),
              _buildQuickStats(),
              const SizedBox(height: 25),
              const Text("Actions Principales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
              const SizedBox(height: 15),
              _buildActionGrid(context, providerExp?.code_expl ?? widget.user.code_expl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String nomExploitation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B4332).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bonjour, ${widget.user.username} 👋",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.gite_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Exploitation : $nomExploitation",
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _smallStatCard("Personnel", isLoading ? "..." : "$nbPersonnel", Icons.people, Colors.blue),
        const SizedBox(width: 15),
        _smallStatCard("Alertes", isLoading ? "..." : "$nbAlertes", Icons.warning_amber_rounded, Colors.orange),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF081C15)),
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, int? currentCodeExpl) {
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
              () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => PersonnelPage(user: widget.user)));
            if (currentCodeExpl != null) _loadDashboardData(currentCodeExpl);
          },
        ),
        _actionCard(
          context,
          "Alertes",
          "Monitoring Live",
          FontAwesomeIcons.warning,
          Colors.redAccent,
              () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => AlertePage(user: widget.user)));
            if (currentCodeExpl != null) _loadDashboardData(currentCodeExpl);
          },
        ),
        _actionCard(
          context,
          "Statistiques",
          "Rapports & Data",
          FontAwesomeIcons.chartPie,
          Colors.teal,
              () {},
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF081C15))),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}