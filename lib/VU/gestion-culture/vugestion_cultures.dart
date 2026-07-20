import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';

// Importations de vos vues (VU)
import 'package:agro_pastoral_app/VU/gestion-culture/vuplanifiercampagne.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vurappotculture.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vuparcelle.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vusuivicampagnes.dart';
import '../gestion-personnel/vuconge.dart'; // Ajuste le chemin si nécessaire

class MyCulturePage extends StatefulWidget {
  final User user;
  final int code_expl; // Récupéré du profil utilisateur

  const MyCulturePage({
    super.key,
    required this.user,
    required this.code_expl
  });

  @override
  State<MyCulturePage> createState() => _MyCulturePageState();
}

class _MyCulturePageState extends State<MyCulturePage> {
  // 🔗 Pas de service dédié à l'exploitation côté Flutter : on interroge
  // directement l'endpoint existant (GET /api/exploitation) et on retient
  // celle qui correspond au code_expl courant.
  final String exploitationUrl = "http://192.168.1.9:3000/api/exploitation";

  String? nomExploitation;

  @override
  void initState() {
    super.initState();
    _chargerNomExploitation();
  }

  Future<void> _chargerNomExploitation() async {
    try {
      final res = await http.get(
        Uri.parse(exploitationUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.user.token}",
        },
      );

      if (res.statusCode != 200) {
        debugPrint("⚠️ Impossible de charger les exploitations (code ${res.statusCode}) : ${res.body}");
        return;
      }

      final List data = jsonDecode(res.body);
      debugPrint("📦 Exploitations reçues : $data");

      // Les clés exactes du JSON peuvent varier ("code_expl", "code exploitation",
      // "codeExpl"...) selon l'endroit où l'exploitation a été créée. On normalise
      // donc chaque clé (minuscule, sans espace/underscore/tiret) pour ne pas
      // dépendre d'un nommage précis.
      Map<String, dynamic> normaliser(Map e) {
        final out = <String, dynamic>{};
        e.forEach((k, v) => out[k.toString().toLowerCase().replaceAll(RegExp(r'[ _-]'), '')] = v);
        return out;
      }

      dynamic trouverValeur(Map<String, dynamic> norm, List<String> cles) {
        for (final cle in cles) {
          if (norm.containsKey(cle) && norm[cle] != null) return norm[cle];
        }
        return null;
      }

      Map<String, dynamic>? matchNormalise;
      for (final e in data) {
        if (e is! Map) continue;
        final norm = normaliser(e);
        final code = trouverValeur(norm, ['codeexpl', 'codeexploitation', 'code']);
        if (code != null && code.toString() == widget.code_expl.toString()) {
          matchNormalise = norm;
          break;
        }
      }

      if (matchNormalise != null) {
        final nom = trouverValeur(matchNormalise, ['nomexpl', 'nomexploitation', 'nom', 'designation', 'name']);
        if (nom != null && mounted) {
          setState(() => nomExploitation = nom.toString());
        } else {
          debugPrint("⚠️ Exploitation trouvée mais aucune clé de nom reconnue : $matchNormalise");
        }
      } else {
        debugPrint("⚠️ Aucune exploitation ne correspond au code_expl ${widget.code_expl}");
      }
    } catch (e) {
      debugPrint("❌ Erreur lors du chargement du nom d'exploitation : $e");
    }
  }

  // --- LOGIQUE DE DÉCONNEXION ---
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Déconnexion"),
          ],
        ),
        content: const Text("Voulez-vous vraiment quitter votre session de travail ?"),
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
              // Nettoie l'historique et redirige vers l'écran de login
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("QUITTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildHeaderInfo(),
                  const SizedBox(height: 15),

                  // 🔴 NOUVEAU : Bouton Congés pour le Technicien Agricole
                  _buildCongeButton(context),

                  const SizedBox(height: 35),
                  _buildSectionTitle("SERVICES DE CULTURE"),
                  const SizedBox(height: 20),
                  _buildMenuGrid(context),
                  const SizedBox(height: 40),
                  _buildLogoutOption(context),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1B4332),
      actions: [
        IconButton(
          tooltip: "Déconnexion",
          icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70),
          onPressed: () => _confirmLogout(context),
        ),
        const SizedBox(width: 10),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "ESPACE CULTURE",
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.8,
              color: Colors.white
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF081C15), Color(0xFF1B4332)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Opacity(
            opacity: 0.1,
            child: const Icon(Icons.eco, size: 150, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFD8F3DC),
            child: const Icon(Icons.engineering_rounded, color: Color(0xFF2D6A4F)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomExploitation ?? "Exploitation #${widget.code_expl}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Connecté en tant que technicien agricole",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔴 DESIGN DU NOUVEAU BOUTON DE CONGÉ
  Widget _buildCongeButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CongePage(user: widget.user),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B4332).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1B4332).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.beach_access_rounded, color: const Color(0xFF1B4332), size: 22),
            const SizedBox(width: 12),
            const Text(
              "DEMANDER / SUIVRE MES CONGÉS",
              style: TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Color(0xFF2D6A4F),
          letterSpacing: 1.2
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        _buildActionCard(
          context,
          "Parcelles",
          "Gestion sols",
          Icons.landscape_rounded,
          const Color(0xFF409167),
          ParcellePage(code_expl: widget.code_expl, user: widget.user),
        ),
        _buildActionCard(
          context,
          "Campagnes",
          "Planifier",
          Icons.event_note_rounded,
          const Color(0xFF52B788),
          PlanificationPage(code_expl: widget.code_expl, user: widget.user),
        ),
        _buildActionCard(
          context,
          "Suivi Réel",
          "Météo & Croissance",
          Icons.speed_rounded,
          const Color(0xFF74C69D),
          // Le suivi affiche directement les campagnes sous forme de cards :
          // un tap sur une card ouvre son suivi (voir vusuivicampagnes.dart).
          SuiviCampagnesPage(code_expl: widget.code_expl, user: widget.user),
        ),
        _buildActionCard(
          context,
          "Analyses",
          "Rapports",
          Icons.analytics_rounded,
          const Color(0xFF95D5B2),
          RapportculturePage(code_expl: widget.code_expl, user: widget.user),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context,
      String title,
      String sub,
      IconData icon,
      Color color,
      Widget targetPage
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage)),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutOption(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
        label: const Text(
          "DÉCONNEXION DU COMPTE",
          style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.1
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: Colors.red.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
