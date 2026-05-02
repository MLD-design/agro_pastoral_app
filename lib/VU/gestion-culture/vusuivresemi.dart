import 'package:flutter/material.dart';
import '../../services/gestion-culture/servicessuivi.dart';
import '../../services/gestion-culture/servicesparcelle.dart';
import '../../services/gestion-culture/servicescampagne.dart';
import '../../models/gestion-culture/modelparcelle.dart';
import '../../models/gestion-culture/modelcampagne.dart';
import 'package:agro_pastoral_app/timeline_widget.dart';

class SuiviPage extends StatefulWidget {
  final int code_expl;
  const SuiviPage({super.key, required this.code_expl});

  @override
  State<SuiviPage> createState() => _SuiviPageState();
}

class _SuiviPageState extends State<SuiviPage> {
  final service = SuiviService();
  final parcelleService = ParcelleService();
  final campagneService = CampagneService();

  List<Parcelle> parcelles = [];
  List<Campagne> campagnes = [];
  int? selectedParcelle;
  Map<int, dynamic> suivis = {};

  // Thème de couleurs
  final Color primaryGreen = const Color(0xFF2D6A4F);
  final Color bgGrey = const Color(0xFFF7F9F7);

  @override
  void initState() {
    super.initState();
    loadParcelles();
  }

  // --- LOGIQUE DE DONNÉES ---

  void loadParcelles() async {
    final data = await parcelleService.getByExploitation(widget.code_expl);
    setState(() => parcelles = data);
    if (data.isNotEmpty) {
      selectedParcelle = data[0].id_cham;
      loadCampagnes(selectedParcelle!);
    }
  }

  void loadCampagnes(int id_cham) async {
    final data = await campagneService.getByParcelle(id_cham);
    setState(() {
      campagnes = data;
      suivis.clear();
    });

    for (var c in data) {
      await service.create(widget.code_expl.toString(), id_cham.toString(), c.id_camp.toString());
      final suivi = await service.get(widget.code_expl.toString(), id_cham.toString(), c.id_camp.toString());
      if (mounted) setState(() => suivis[c.id_camp] = suivi);
    }
  }

  // Calcul réel de la progression
  double calculerProgression(dynamic data) {
    if (data == null) return 0.0;
    int totalEtapes = 0;
    int etapesCompletes = 0;

    ['semis', 'traitement', 'recolte'].forEach((type) {
      if (data[type] != null) {
        List etapes = data[type];
        totalEtapes += etapes.length;
        etapesCompletes += etapes.where((e) => e['statut'] == true || e['statut'] == 1).length;
      }
    });
    return totalEtapes == 0 ? 0.0 : etapesCompletes / totalEtapes;
  }

  void updateStep(int campId, String type, int index) async {
    await service.update(widget.code_expl.toString(), selectedParcelle.toString(), campId.toString(), type, index);
    final updated = await service.get(widget.code_expl.toString(), selectedParcelle.toString(), campId.toString());
    setState(() => suivis[campId] = updated);
  }

  // --- INTERFACE (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Suivi des Campagnes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildParcelleBar(),
          const SizedBox(height: 10),
          Expanded(child: _buildCampagneGrid()),
        ],
      ),
    );
  }

  Widget _buildParcelleBar() {
    return Container(
      height: 65,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: parcelles.length,
        itemBuilder: (context, index) {
          final p = parcelles[index];
          final bool isSelected = selectedParcelle == p.id_cham;
          return GestureDetector(
            onTap: () {
              setState(() => selectedParcelle = p.id_cham);
              loadCampagnes(p.id_cham);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8)] : [],
              ),
              child: Center(
                child: Text(p.nom_cham, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCampagneGrid() {
    if (campagnes.isEmpty) return const Center(child: Text("Aucune campagne trouvée."));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campagnes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final c = campagnes[index];
        final data = suivis[c.id_camp];
        double progression = calculerProgression(data);

        return _buildCampagneCard(c, data, progression);
      },
    );
  }

  Widget _buildCampagneCard(Campagne c, dynamic data, double progression) {
    Color progressColor = progression < 0.3 ? Colors.orange : (progression < 0.8 ? Colors.blue : Colors.green);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showDetailSheet(c, data),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.eco_rounded, color: progressColor, size: 24),
                  Text("${(progression * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: progressColor)),
                ],
              ),
              const SizedBox(height: 12),
              Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(c.statut, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(value: progression, backgroundColor: Colors.grey[100], color: progressColor, minHeight: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(Campagne c, dynamic data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            _buildSheetHeader(c),
            const Divider(height: 40),
            Expanded(
              child: data == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                children: [
                  _buildTimelineSection("Semis", data['semis'], c.id_camp, "semis", Colors.blue),
                  _buildTimelineSection("Traitement", data['traitement'], c.id_camp, "traitement", Colors.orange),
                  _buildTimelineSection("Récolte", data['recolte'], c.id_camp, "recolte", Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(Campagne c) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: primaryGreen, child: const Icon(Icons.layers, color: Colors.white)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.nom_camp, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Suivi de l'évolution du champ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(String title, List steps, int campId, String type, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 10),
        TimelineWidget(
          title: "",
          steps: steps,
          onTap: (i) => updateStep(campId, type, i),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}