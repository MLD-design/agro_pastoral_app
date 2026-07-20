import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/gestion-stock/modelstock.dart';
import '../../services/gestion-stock/servicesstock.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../gestion-personnel/vuconge.dart'; // Import ajouté
import 'vuformulaireaddstock.dart';

class StockPage extends StatefulWidget {
  final User user;
  const StockPage({super.key, required this.user});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Stock> allStocks = [];
  List<Stock> displayedStocks = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadStocks();
  }

  Future<void> loadStocks() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await StockService.getStocksByExpl(widget.user.code_expl, widget.user.token);
      if (mounted) {
        setState(() {
          allStocks = data;
          _filterStocks(searchQuery);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Déconnexion"),
        content: const Text("Souhaitez-vous fermer votre session ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
            child: const Text("QUITTER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _filterStocks(String query) {
    setState(() {
      searchQuery = query;
      displayedStocks = allStocks.where((s) => s.nom.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int alertCount = allStocks.where((s) => s.quantite <= s.seuilAlerte).length;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF9), // Couleur page Personnel
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1B4332), // Couleur page Personnel
          leading: IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.white70),
            onPressed: _confirmLogout,
          ),
          title: const Text("GESTION STOCKS", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white, fontSize: 18)),
          centerTitle: true,
          actions: [
            // 🔴 AJOUT DU MODULE CONGÉ
            IconButton(
              icon: const Icon(Icons.event_available, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CongePage(user: widget.user))),
            ),
            IconButton(onPressed: loadStocks, icon: const Icon(Icons.refresh, color: Colors.white)),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildHeaderDashboard(alertCount),
            _buildTabBarHeader(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
                  : TabBarView(
                children: [
                  _buildGrid("intrant"), _buildGrid("aliment"),
                  _buildGrid("medicament"), _buildGrid("equipement"),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF1B4332), // Couleur page Personnel
          onPressed: () async {
            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddStockPage(user: widget.user)));
            if (res == true) loadStocks();
          },
          label: const Text("NOUVEAU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add_box_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderDashboard(int alertCount) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B4332), // Couleur page Personnel
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 20),
          Row(
            children: [
              _infoMiniCard("Mes Produits", "${allStocks.length}", Icons.inventory_2),
              const SizedBox(width: 15),
              _infoMiniCard("Alertes", "$alertCount", Icons.warning_amber_rounded, color: alertCount > 0 ? Colors.orangeAccent : Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoMiniCard(String title, String value, IconData icon, {Color color = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _filterStocks,
      decoration: InputDecoration(
        hintText: "Chercher dans mon stock...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF1B4332)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTabBarHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const TabBar(
        isScrollable: true,
        labelColor: Color(0xFF1B4332), // Couleur page Personnel
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF1B4332),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          Tab(text: "📦 Intrants"),
          Tab(text: "🌾 Aliments"),
          Tab(text: "💊 Médicaments"),
          Tab(text: "🛠 Équipements"),
        ],
      ),
    );
  }

  Widget _buildGrid(String type) {
    final filtered = displayedStocks.where((s) => s.type == type).toList();
    if (filtered.isEmpty) return _buildEmptyState();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65),
      itemBuilder: (_, i) => _buildStockCard(filtered[i]),
    );
  }

  Widget _buildStockCard(Stock s) {
    bool isLow = s.quantite <= s.seuilAlerte;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Expanded(flex: 4, child: Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: s.imagePath != null && File(s.imagePath!).existsSync() ? Image.file(File(s.imagePath!), fit: BoxFit.cover) : Container(color: const Color(0xFFF1F8E9), child: Icon(Icons.inventory_2_outlined, color: Colors.green.shade200, size: 50)))]),),
          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(children: [Text(s.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("${s.quantite}", style: TextStyle(color: isLow ? Colors.red : Colors.black, fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(width: 4), Text(s.unite, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))])]), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionBtn(Icons.remove, Colors.orange, () => _showMouvement(s, false)), _actionBtn(Icons.add, Colors.green, () => _showMouvement(s, true))])]))),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)));
  }

  void _showMouvement(Stock s, bool entree) {
    final controller = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), const SizedBox(height: 20), Text(entree ? "ENTRÉE DE STOCK" : "SORTIE DE STOCK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: entree ? Colors.green : Colors.orange)), const SizedBox(height: 25), TextField(controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), autofocus: true, decoration: InputDecoration(hintText: "Quantité", suffixText: s.unite, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))), const SizedBox(height: 25), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async { if (controller.text.isEmpty) return; int qte = int.parse(controller.text); entree ? await StockService.entree(s.id_stock, qte, widget.user.token) : await StockService.sortie(s.id_stock, qte, widget.user.token); Navigator.pop(context); loadStocks(); }, child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(height: 25)])));
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300), const SizedBox(height: 10), const Text("Aucun produit trouvé", style: TextStyle(color: Colors.grey))]));
}