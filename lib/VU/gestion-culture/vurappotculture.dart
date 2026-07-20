import 'package:flutter/material.dart';
import '../../models/gestion-culture/modelparcelle.dart';
import '../../models/gestion-culture/modelcampagne.dart';
import '../../models/gestion-culture/modelrapport.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-culture/servicesparcelle.dart';
import '../../services/gestion-culture/servicescampagne.dart';
import '../../services/gestion-culture/servicesrapport.dart';

class RapportculturePage extends StatefulWidget {
  final int code_expl;
  final User user;

  const RapportculturePage({super.key, required this.code_expl, required this.user});

  @override
  State<RapportculturePage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportculturePage> {
  final rapportService = RapportService();
  final parcelleService = ParcelleService();
  final campagneService = CampagneService();

  List<Parcelle> parcelles = [];
  List<Campagne> campagnes = [];
  int? selectedParcelle;
  int? selectedCampagne;
  RapportCulture? rapport;
  bool isLoading = false;
  String? erreur;

  final Color primaryGreen = const Color(0xFF1B4332);
  final Color accentGreen = const Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final data = await parcelleService.getByExploitation(widget.code_expl, widget.user.token);
    if (mounted) setState(() => parcelles = data);
  }

  void _loadCampagnes(int idCham) async {
    final data = await campagneService.getByParcelle(idCham, widget.user.token);
    if (!mounted) return;
    setState(() {
      campagnes = data;
      selectedCampagne = null;
      rapport = null;
      erreur = null;
    });
  }

  void loadRapport() async {
    setState(() { isLoading = true; erreur = null; rapport = null; });
    try {
      // Le code_expl est déduit du token côté serveur.
      final data = await rapportService.getRapport(
        selectedParcelle!,
        selectedCampagne!,
        widget.user.token,
      );
      if (!mounted) return;
      setState(() { rapport = data; isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        erreur = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'RECOLTEE':
        return accentGreen;
      case 'RETARD':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  String _libelleStatut(String statut) {
    switch (statut) {
      case 'RECOLTEE':
        return "Récolte clôturée";
      case 'RETARD':
        return "En retard sur l'échéance";
      default:
        return "En cours";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Analyses & Rapports", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSelectionHeader(),
            const SizedBox(height: 25),
            if (rapport != null)
              _buildRapportContent()
            else if (erreur != null)
              _buildErrorState()
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  // --- FILTRES DE SÉLECTION ---
  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          _buildCustomDropdown(
            hint: "Sélectionner une parcelle",
            value: selectedParcelle,
            items: parcelles.map((p) => DropdownMenuItem(value: p.id_cham, child: Text(p.nom_cham))).toList(),
            onChanged: (v) {
              setState(() => selectedParcelle = v);
              if (v != null) _loadCampagnes(v);
            },
            icon: Icons.terrain_rounded,
          ),
          const SizedBox(height: 15),
          _buildCustomDropdown(
            hint: "Sélectionner une campagne",
            value: selectedCampagne,
            items: campagnes.map((c) => DropdownMenuItem(value: c.id_camp, child: Text(c.nom_camp))).toList(),
            onChanged: (v) => setState(() => selectedCampagne = v),
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (selectedCampagne != null && selectedParcelle != null && !isLoading) ? loadRapport : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("GÉNÉRER LE BILAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTENU DU RAPPORT ---
  Widget _buildRapportContent() {
    final r = rapport!;
    return Column(
      children: [
        _buildStatCard("PHASE SEMIS", Icons.grass_rounded, [
          _rowInfo("Semis", r.semisValide ? "Validé${r.variete != null && r.variete!.isNotEmpty ? ' (${r.variete})' : ''}" : "Non enregistré",
              r.semisValide ? accentGreen : Colors.grey),
          _rowInfo("Quantité semée", "${r.quantiteSemee.toStringAsFixed(1)} kg", Colors.blue),
          _rowInfo("Levée", r.leveeValidee ? "Validée${r.tauxLevee != null ? ' (${r.tauxLevee}%)' : ''}" : "Non validée",
              r.leveeValidee ? accentGreen : Colors.grey),
          _rowInfo("Observations de croissance", "${r.nombreObservations}", Colors.teal),
        ]),
        const SizedBox(height: 15),
        _buildStatCard("PHASE RÉCOLTE", Icons.agriculture_rounded, [
          _rowInfo("Passages de récolte", "${r.nombrePassagesRecolte}", Colors.brown),
          _rowInfo("Quantité totale récoltée",
              "${r.quantiteTotaleRecoltee.toStringAsFixed(1)} ${r.uniteRecolte ?? ''}", Colors.green),
          _rowInfo("Récolte", r.recolteCloturee ? "Clôturée" : "En cours", r.recolteCloturee ? accentGreen : Colors.orange),
        ]),
        const SizedBox(height: 15),
        _buildStatCard("SYNTHÈSE OPÉRATIONNELLE", Icons.analytics, [
          _rowInfo("Traitements phytos", "${r.nombreTraitements} intervention(s)", Colors.orange),
        ]),
        const SizedBox(height: 15),
        _buildStatCard("STATUT FINAL", Icons.assignment_turned_in, [
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _couleurStatut(r.statutGlobal).withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _libelleStatut(r.statutGlobal),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: _couleurStatut(r.statutGlobal), fontSize: 16),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryGreen),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Icon(Icons.insert_chart_outlined_rounded, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        const Text(
          "Sélectionnez une parcelle et une campagne\npour générer le rapport détaillé.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent.withOpacity(0.6)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(erreur ?? "Une erreur est survenue.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({required String hint, required int? value, required List<DropdownMenuItem<int>> items, required Function(int?) onChanged, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          items: items,
          onChanged: onChanged,
          icon: Icon(icon, color: primaryGreen, size: 20),
        ),
      ),
    );
  }
}
