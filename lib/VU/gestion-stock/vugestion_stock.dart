import 'dart:io';
import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';
import 'package:flutter/material.dart';
import '../../models/gestion-stock/modelstock.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../services/gestion-stock/servicesstock.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import 'vuformulaireaddstock.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key, required User user});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Stock> stocks = [];
  List<Exploitation> exploitations = [];
  int? selectedExpl;
  final exploitationService = ExploitationService();

  @override
  void initState() {
    super.initState();
    loadExploitations();
  }

  Future<void> loadExploitations() async {
    exploitations = await exploitationService.getAll();
    setState(() {});
  }

  Future<void> loadStocks() async {
    if (selectedExpl == null) return;
    stocks = await StockService.getStocksByExpl(selectedExpl!);
    setState(() {});
  }

  ImageProvider getImage(Stock s) {
    if (s.imagePath != null && s.imagePath!.isNotEmpty) {
      return FileImage(File(s.imagePath!));
    }
    return const AssetImage("assets/images/default.png");
  }

  void showDialogMouvement(Stock s, bool entree) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(entree ? "📈 Entrée Stock" : "📉 Sortie Stock"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Quantité en ${s.unite}",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: entree ? Colors.green : Colors.red),
            onPressed: () async {
              if (controller.text.isEmpty) return;
              int qte = int.parse(controller.text);
              entree ? await StockService.entree(s.id_stock, qte) : await StockService.sortie(s.id_stock, qte);
              Navigator.pop(context);
              await loadStocks();
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget buildGrid(String type) {
    final filtered = stocks.where((s) => s.type == type).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const Text("Aucun article dans cette catégorie", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, i) {
        final s = filtered[i];
        bool isLow = s.quantite <= s.seuilAlerte;
        return _buildStockCard(s, isLow);
      },
    );
  }

  Widget _buildStockCard(Stock s, bool isLow) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: getImage(s), fit: BoxFit.cover),
                  if (isLow) Container(color: Colors.red.withOpacity(0.1)),
                  Positioned(
                    top: 8, right: 8,
                    child: isLow
                        ? const CircleAvatar(backgroundColor: Colors.red, radius: 12, child: Icon(Icons.priority_high, size: 15, color: Colors.white))
                        : Container(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(s.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                  const SizedBox(height: 4),
                  Text(
                    "${s.quantite} ${s.unite}",
                    style: TextStyle(color: isLow ? Colors.red : Colors.green[700], fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(Icons.remove, Colors.red, () => showDialogMouvement(s, false)),
                      _actionButton(Icons.add, Colors.green, () => showDialogMouvement(s, true)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int alertCount = stocks.where((s) => s.quantite <= s.seuilAlerte).length;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1B5E20),
          title: const Text("Gestion des Stocks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          actions: [
            if (alertCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Badge(
                    label: Text("$alertCount"),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                ),
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Intrants"), Tab(text: "Aliments"),
              Tab(text: "Médicaments"), Tab(text: "Équipements"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildExploitationSelector(),
            Expanded(
              child: selectedExpl == null
                  ? const Center(child: Text("Sélectionnez une exploitation pour voir le stock"))
                  : TabBarView(
                children: [
                  buildGrid("intrant"), buildGrid("aliment"),
                  buildGrid("medicament"), buildGrid("equipement"),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF1B5E20),
          onPressed: () async {
            if (selectedExpl == null) return;
            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddStockPage()));
            if (res == true) loadStocks();
          },
          label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildExploitationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: DropdownButtonFormField<int>(
        value: selectedExpl,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.business),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        hint: const Text("Choisir une exploitation"),
        items: exploitations.map((e) => DropdownMenuItem(value: e.code_expl, child: Text(e.nom_expl))).toList(),
        onChanged: (value) async {
          setState(() => selectedExpl = value);
          await loadStocks();
        },
      ),
    );
  }
}