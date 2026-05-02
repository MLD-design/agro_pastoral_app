import 'package:flutter/material.dart';
import 'package:agro_pastoral_app/VU/gestion-personnel/vuconge.dart';
import 'package:agro_pastoral_app/VU/gestion-personnel/vucontrat.dart';
import 'package:agro_pastoral_app/VU/gestion-personnel/vupaie.dart';
import 'package:agro_pastoral_app/VU/gestion-personnel/vupersonnel.dart';

class PersonnelPage extends StatefulWidget {
  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // Fond gris très léger
      body: CustomScrollView(
        slivers: [
          // En-tête stylisé avec dégradé
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Ressources Humaines",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.groups_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Contenu de la page
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilotez votre équipe",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gérez les contrats, les absences et les paies de vos collaborateurs en un seul endroit.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Grille de navigation
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuCard(
                        context,
                        "Personnel",
                        "Inscrire et gérer",
                        Icons.person_add_rounded,
                        Colors.blue,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyPersonnelPage())),
                      ),
                      _buildMenuCard(
                        context,
                        "Contrats",
                        "Documents légaux",
                        Icons.description_rounded,
                        Colors.orange,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContratPage())),
                      ),
                      _buildMenuCard(
                        context,
                        "Congés",
                        "Suivi des absences",
                        Icons.event_busy_rounded,
                        Colors.redAccent,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => CongePage())),
                      ),
                      _buildMenuCard(
                        context,
                        "Paiements",
                        "Salaires et primes",
                        Icons.payments_rounded,
                        Colors.green,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaiementPage())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour créer une carte de menu propre
  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}