// lib/VU/gestion-culture/vusuivicampagnes.dart
import 'package:flutter/material.dart';
import '../../services/gestion-culture/servicescampagne.dart';
import '../../services/gestion-culture/servicesparcelle.dart';
import '../../models/gestion-culture/modelcampagne.dart';
import '../../models/gestion-culture/modelparcelle.dart';
import '../../models/gestion-compte/modeluser.dart';
import 'vusuivresemi.dart';

class SuiviCampagnesPage extends StatefulWidget {
  final int code_expl;
  final User user;

  const SuiviCampagnesPage({super.key, required this.code_expl, required this.user});

  @override
  State<SuiviCampagnesPage> createState() => _SuiviCampagnesPageState();
}

class _SuiviCampagnesPageState extends State<SuiviCampagnesPage> {
  final CampagneService campagneService = CampagneService();
  final ParcelleService parcelleService = ParcelleService();

  // Palette de couleurs PRO
  final Color primaryGreen = const Color(0xFF0F3021);
  final Color cardGreen = const Color(0xFF1B4332);
  final Color background = const Color(0xFFF0F4F2);

  List<Campagne> campagnes = [];
  Map<int, String> nomsParcelles = {};
  bool isLoading = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { isLoading = true; erreur = null; });
    try {
      final results = await Future.wait([
        campagneService.getByExploitation(widget.code_expl, widget.user.token),
        parcelleService.getByExploitation(widget.code_expl, widget.user.token),
      ]);
      final campagnesData = results[0] as List<Campagne>;
      final parcellesData = results[1] as List<Parcelle>;

      campagnesData.sort((a, b) => b.date_debut.compareTo(a.date_debut));

      if (!mounted) return;
      setState(() {
        campagnes = campagnesData;
        nomsParcelles = {for (var p in parcellesData) p.id_cham: p.nom_cham};
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { erreur = "Erreur de synchronisation."; isLoading = false; });
    }
  }

  Color _couleurStatut(String statusCouleur) {
    switch (statusCouleur) {
      case 'ROUGE': return const Color(0xFFFF5757);
      case 'ORANGE': return const Color(0xFFFFAB40);
      default: return const Color(0xFF00E676);
    }
  }

  IconData _iconeEtape(String etape) {
    switch (etape) {
      case 'Récoltée': return Icons.agriculture_rounded;
      case 'Traitement': return Icons.science_rounded;
      case 'Semis': return Icons.spa_rounded;
      default: return Icons.grass_rounded;
    }
  }

  String _formatDate(String dateIso) {
    try {
      final date = dateIso.split('T')[0].split('-');
      return "${date[2]}/${date[1]}";
    } catch (_) { return dateIso; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        title: const Text("Suivi Campagnes", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.5)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        color: primaryGreen,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryGreen))
            : erreur != null
            ? _buildEtatVide(erreur!, Icons.warning_amber_rounded)
            : campagnes.isEmpty
            ? _buildEtatVide("Aucune campagne active.", Icons.landscape_rounded)
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: campagnes.length,
          itemBuilder: (context, index) => _buildCampagneCard(campagnes[index]),
        ),
      ),
    );
  }

  Widget _buildEtatVide(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: primaryGreen.withOpacity(0.1)),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: primaryGreen.withOpacity(0.6), fontSize: 18, height: 1.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCampagneCard(Campagne c) {
    final statusColor = _couleurStatut(c.status_couleur);
    final nomParcelle = nomsParcelles[c.id_cham] ?? "Parcelle #${c.id_cham}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: cardGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SuiviPage(
              idCham: c.id_cham, idCamp: c.id_camp, nomCampagne: c.nom_camp, user: widget.user,
            ))).then((_) => _charger());
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_iconeEtape(c.etape_actuelle), color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white, letterSpacing: 0.2)),
                          const SizedBox(height: 2),
                          Text(nomParcelle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                      ),
                      child: Text(c.etape_actuelle.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    _InfoPill(icon: Icons.event_seat_rounded, label: "Début", value: _formatDate(c.date_debut)),
                    const SizedBox(width: 20),
                    _InfoPill(icon: Icons.event_available_rounded, label: "Fin prévue", value: _formatDate(c.date_fin)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.5)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}