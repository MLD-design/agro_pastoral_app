import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';
import 'package:flutter/material.dart';
import '../../services/gestion-finance/servicesfinance.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key, required User user});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List<Exploitation> exploitations = [];
  int? selectedExpl;
  List depenses = [];
  List recettes = [];
  Map rentabilite = {};
  String filtre = "all";
  final exploitationService = ExploitationService();

  @override
  void initState() {
    super.initState();
    loadExploitations();
  }

  Future loadExploitations() async {
    exploitations = await exploitationService.getAll();
    setState(() {});
  }

  Future loadData() async {
    if (selectedExpl == null) return;
    depenses = await FinanceService.getDepenses(selectedExpl!);
    recettes = await FinanceService.getRecettes(selectedExpl!);
    rentabilite = await FinanceService.getRentabilite(selectedExpl!);
    setState(() {});
  }

  // --- DESIGN : CARTE DE SOLDE "GOLDEN AGRI" ---
  Widget _buildPremiumBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B1E), Color(0xFF1B4332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SOLDE DISPONIBLE", style: TextStyle(color: Colors.white60, letterSpacing: 1.5, fontSize: 12)),
          const SizedBox(height: 10),
          Text(
            "${rentabilite['benefice'] ?? 0} FCFA",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildMiniIndicator(Icons.trending_up, "Entrées", "${rentabilite['recettes_tot'] ?? 0}", Colors.greenAccent),
              const Spacer(),
              _buildMiniIndicator(Icons.trending_down, "Sorties", "${rentabilite['depenses_tot'] ?? 0}", Colors.orangeAccent),
              const Spacer(),
              _buildMiniIndicator(Icons.pie_chart, "Rentab.", "${rentabilite['rentabilite'] ?? 0}%", Colors.blueAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniIndicator(IconData icon, String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11))]),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // --- DESIGN : ACTIONS RAPIDES STYLISÉES ---
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _btnAction("RECETTE", Icons.add_circle, Colors.green, () => _showTransactionDialog(false)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _btnAction("DÉPENSE", Icons.remove_circle, Colors.redAccent, () => _showTransactionDialog(true)),
        ),
      ],
    );
  }

  Widget _btnAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // --- DESIGN : MODAL DE SAISIE LUXE ---
  void _showTransactionDialog(bool isDepense) {
    final montantCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(isDepense ? "DÉPENSER" : "ENCAISSER", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDepense ? Colors.red : Colors.green)),
            const SizedBox(height: 25),
            TextField(controller: textCtrl, decoration: _inputDecoration("Description", Icons.edit_note)),
            const SizedBox(height: 15),
            TextField(controller: montantCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration("Montant FCFA", Icons.payments)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isDepense ? Colors.red : Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  if (selectedExpl == null) return;
                  isDepense
                      ? await FinanceService.addDepense({"libelle": textCtrl.text, "montant": int.parse(montantCtrl.text), "code_expl": selectedExpl})
                      : await FinanceService.addRecette({"source": textCtrl.text, "montant": int.parse(montantCtrl.text), "code_expl": selectedExpl});
                  Navigator.pop(context); loadData();
                },
                child: const Text("VALIDER LA TRANSACTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon),
      filled: true, fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  // --- DESIGN : HISTORIQUE ET FILTRES (FIX OVERFLOW) ---
  Widget _buildHistorySection() {
    List items = [];
    if (filtre == "all" || filtre == "depense") items.addAll(depenses.map((e) => {...e, "type": "depense"}));
    if (filtre == "all" || filtre == "recette") items.addAll(recettes.map((e) => {...e, "type": "recette"}));
    items.sort((a, b) => b['date'].compareTo(a['date']));

    return Column(
      children: [
        Row(
          children: [
            const Text("Historique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            // RÉSOLUTION DE L'OVERFLOW ICI
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  _filterChip("Tous", "all"),
                  _filterChip("Dép.", "depense"),
                  _filterChip("Rec.", "recette"),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        ...items.map((item) => _buildTransactionTile(item)).toList(),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    bool sel = filtre == value;
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.black)),
        selected: sel,
        selectedColor: const Color(0xFF1B4332),
        onSelected: (s) => setState(() => filtre = value),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic item) {
    bool isDep = item['type'] == "depense";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: isDep ? Colors.red[50] : Colors.green[50], child: Icon(isDep ? Icons.upload : Icons.download, color: isDep ? Colors.red : Colors.green, size: 18)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isDep ? item['libelle'] : item['source'], style: const TextStyle(fontWeight: FontWeight.bold)), Text(item['date'], style: TextStyle(fontSize: 11, color: Colors.grey[500]))])),
          Text("${isDep ? '-' : '+'}${item['montant']} F", style: TextStyle(fontWeight: FontWeight.w900, color: isDep ? Colors.red : Colors.green, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.black,
        title: const Text("Tableau de Bord Financier", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sélecteur d'exploitation
            DropdownButtonFormField(
              decoration: _inputDecoration("Mon Exploitation", Icons.agriculture),
              value: selectedExpl,
              items: exploitations.map((e) => DropdownMenuItem(value: e.code_expl, child: Text(e.nom_expl))).toList(),
              onChanged: (v) { setState(() => selectedExpl = v as int); loadData(); },
            ),
            const SizedBox(height: 25),
            if (selectedExpl != null) ...[
              _buildPremiumBalanceCard(),
              const SizedBox(height: 25),
              _buildActionButtons(),
              const SizedBox(height: 35),
              _buildHistorySection(),
            ] else
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Sélectionnez une exploitation pour commencer"))),
          ],
        ),
      ),
    );
  }
}