import 'package:flutter/material.dart';
import 'package:agro_pastoral_app/models/gestion-culture/modelparcelle.dart';
import 'package:agro_pastoral_app/services/gestion-culture/servicesparcelle.dart';
import '../../models/gestion-compte/modeluser.dart';

class ParcellePage extends StatefulWidget {
  final int code_expl;
  final User user; // Ajout de l'utilisateur pour le token
  const ParcellePage({super.key, required this.code_expl, required this.user});

  @override
  State<ParcellePage> createState() => _ParcellePageState();
}

class _ParcellePageState extends State<ParcellePage> {
  final service = ParcelleService();
  List<Parcelle> parcelles = [];
  bool isLoading = true;

  // Couleurs cohérentes avec ton thème Agriculture
  final Color primaryGreen = const Color(0xFF1B4332);
  final Color accentGreen = const Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() async {
    setState(() => isLoading = true);
    try {
      // On passe le code_expl et le token au service
      final result = await service.getByExploitation(widget.code_expl, widget.user.token);
      setState(() {
        parcelles = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur parcelles: $e");
    }
  }

  // Dialogue d'ajout/modification
  void showParcelleDialog({Parcelle? parcelle}) {
    final isEdit = parcelle != null;
    final controller = TextEditingController(text: isEdit ? parcelle.nom_cham : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 25, right: 25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(isEdit ? "MODIFIER LA PARCELLE" : "NOUVELLE PARCELLE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryGreen)),
            const SizedBox(height: 25),
            TextField(
              controller: controller,
              decoration: _inputDecoration("Nom du champ / parcelle", Icons.terrain),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  final p = Parcelle(
                      id_cham: isEdit ? parcelle.id_cham : 0,
                      nom_cham: controller.text.trim(),
                      code_expl: widget.code_expl
                  );

                  if (isEdit) {
                    await service.update(p.id_cham, p, widget.user.token);
                  } else {
                    await service.add(p, widget.user.token);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    refresh();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(isEdit ? "METTRE À JOUR" : "ENREGISTRER LA TERRE",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Mon Domaine", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showParcelleDialog(),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("PARCELLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Text("Inventaire des parcelles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: parcelles.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: parcelles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
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
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryGreen, accentGreen]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CAPACITÉ D'EXPLOITATION", style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text("${parcelles.length} Parcelles",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildParcelleCard(Parcelle parcelle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Icon(Icons.layers_outlined, color: primaryGreen, size: 20),
                  ),
                  const Spacer(),
                  Text(parcelle.nom_cham,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text("Terre active", style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Positioned(
              top: 5, right: 5,
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (value) async {
                  if (value == 'edit') showParcelleDialog(parcelle: parcelle);
                  if (value == 'delete') {
                    await service.delete(parcelle.id_cham, widget.user.token);
                    refresh();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 10), Text("Modifier")])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 10), Text("Supprimer", style: TextStyle(color: Colors.red))])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_rounded, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Votre domaine est vide", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          TextButton(onPressed: () => showParcelleDialog(), child: Text("Enregistrer une parcelle", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: primaryGreen),
      filled: true, fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }
}