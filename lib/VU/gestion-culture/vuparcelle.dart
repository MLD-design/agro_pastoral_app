import 'package:flutter/material.dart';
import 'package:agro_pastoral_app/models/gestion-culture/modelparcelle.dart';
import 'package:agro_pastoral_app/services/gestion-culture/servicesparcelle.dart';

class ParcellePage extends StatefulWidget {
  final int code_expl;
  const ParcellePage({super.key, required this.code_expl});

  @override
  State<ParcellePage> createState() => _ParcellePageState();
}

class _ParcellePageState extends State<ParcellePage> {
  final service = ParcelleService();
  final nomController = TextEditingController();
  List<Parcelle> parcelles = [];
  final Color primaryGreen = const Color(0xFF1B5E20); // Vert profond
  final Color accentGreen = const Color(0xFF81C784);

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() async {
    final result = await service.getByExploitation(widget.code_expl);
    setState(() => parcelles = result);
  }

  // Dialogue d'ajout/modification stylisé
  void showParcelleDialog({Parcelle? parcelle}) {
    final isEdit = parcelle != null;
    final controller = TextEditingController(text: isEdit ? parcelle.nom_cham : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(isEdit ? "Modifier la parcelle" : "Nouvelle Parcelle",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Nom du champ",
                prefixIcon: Icon(Icons.grass, color: primaryGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  if (isEdit) {
                    await service.update(parcelle.id_cham, Parcelle(id_cham: parcelle.id_cham, nom_cham: controller.text, code_expl: parcelle.code_expl));
                  } else {
                    await service.add(Parcelle(id_cham: DateTime.now().millisecondsSinceEpoch, nom_cham: controller.text, code_expl: widget.code_expl));
                  }
                  Navigator.pop(context);
                  refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(isEdit ? "Mettre à jour" : "Ajouter au domaine", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Mon Domaine", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showParcelleDialog(),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Parcelle", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Vos Terres", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: parcelles.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: parcelles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) => _buildParcelleCard(parcelles[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryGreen, accentGreen]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Statistiques", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text("${parcelles.length} Parcelles enregistrées",
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildParcelleCard(Parcelle parcelle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.terrain_rounded, color: primaryGreen, size: 30),
                ),
                const Spacer(),
                Text(parcelle.nom_cham,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("Exploitation active", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            top: 5, right: 5,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (value) async {
                if (value == 'edit') showParcelleDialog(parcelle: parcelle);
                if (value == 'delete') {
                  await service.delete(parcelle.id_cham);
                  refresh();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Modifier")])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Supprimer", style: TextStyle(color: Colors.red))])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Aucune parcelle trouvée", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          TextButton(onPressed: () => showParcelleDialog(), child: Text("Ajoutez votre première terre", style: TextStyle(color: primaryGreen))),
        ],
      ),
    );
  }
}