import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';
import 'package:flutter/material.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vusuivresemi.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vuplanifiercampagne.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vurappotculture.dart';
import 'package:agro_pastoral_app/VU/gestion-culture/vuparcelle.dart';
import 'package:agro_pastoral_app/services/gestion-exploitation/servicesexploitation.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';

class MyCulturePage extends StatefulWidget {
  final int code_expl;
  MyCulturePage({required this.code_expl, required User user,});

  @override
  State<MyCulturePage> createState() => _MyCulturePageState();
}

class _MyCulturePageState extends State<MyCulturePage> {
  List<Exploitation> exploitations = [];
  Exploitation? selectedExploitation;
  final exploitationService = ExploitationService();

  @override
  void initState() {
    super.initState();
    loadExploitations();
  }

  void loadExploitations() async {
    final data = await exploitationService.getAll();
    setState(() => exploitations = data);
  }

  bool checkExploitation() {
    if (selectedExploitation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez choisir une exploitation pour continuer"),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: CustomScrollView(
        slivers: [
          // Header avec courbe et texte d'accueil
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF1B4332),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20, top: -20,
                      child: Icon(Icons.eco, size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
              title: const Text("Ma Culture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- SÉLECTEUR D'EXPLOITATION ---
                  _buildGlassDropdown(),

                  const SizedBox(height: 30),

                  // --- VOS TEXTES RÉINTRODUITS ET STYLISÉS ---
                  Text(
                    "Organisez et Suivez vos activités agricoles",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[800],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "À mesure que vous réalisez une de ces fonctionnalités, les données opérationnelles sont associées aux parcelles.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // Titre d'appel à l'action
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "COMMENCER PAR ENREGISTRER VOTRE PARCELLE",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- GRILLE DE CARTES INTERACTIVES ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.85,
                    children: [
                      _buildPremiumCard(
                        "Enregistrer Parcelles",
                        Icons.map_rounded,
                        Colors.orange,
                            () => _navigate(ParcellePage(code_expl: selectedExploitation!.code_expl)),
                      ),
                      _buildPremiumCard(
                        "Planifier Campagnes",
                        Icons.calendar_today_rounded,
                        Colors.green,
                            () => _navigate(PlanificationPage(code_expl: selectedExploitation!.code_expl)),
                      ),
                      _buildPremiumCard(
                        "Suivre Activités",
                        Icons.auto_graph_rounded,
                        Colors.blue,
                            () => _navigate(SuiviPage(code_expl: selectedExploitation!.code_expl)),
                      ),
                      _buildPremiumCard(
                        "Rapports de Suivi",
                        Icons.insert_chart_rounded,
                        Colors.purple,
                            () => _navigate(RapportculturePage(code_expl: selectedExploitation!.code_expl)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIQUE DE NAVIGATION ---
  void _navigate(Widget page) {
    if (checkExploitation()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  // --- WIDGET DROPDOWN AMÉLIORÉ ---
  Widget _buildGlassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: DropdownButtonFormField<Exploitation>(
        value: selectedExploitation,
        decoration: const InputDecoration(border: InputBorder.none, icon: Icon(Icons.business_center, color: Color(0xFF2D6A4F))),
        hint: const Text("Choisir une exploitation", style: TextStyle(fontWeight: FontWeight.w500)),
        items: exploitations.map((exp) => DropdownMenuItem(value: exp, child: Text(exp.nom_expl))).toList(),
        onChanged: (v) => setState(() => selectedExploitation = v),
      ),
    );
  }

  // --- CARTE PREMIUM ---
  Widget _buildPremiumCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge d'icône
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 35),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4332)),
                ),
                const SizedBox(height: 8),
                Icon(Icons.arrow_forward_rounded, size: 16, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}