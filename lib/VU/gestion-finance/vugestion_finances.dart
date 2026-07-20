import 'package:flutter/material.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-finance/servicesfinance.dart';
import '../gestion-personnel/vuconge.dart';

class FinancePage extends StatefulWidget {
  final User user;
  const FinancePage({super.key, required this.user});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List depenses = [];
  List recettes = [];
  Map rentabilite = {};
  String filtre = "all";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // --- LOGIQUE DE DÉCONNEXION ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment quitter l'application ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("DÉCONNEXION", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future loadData() async {
    depenses = await FinanceService.getDepenses(widget.user.code_expl);
    recettes = await FinanceService.getRecettes(widget.user.code_expl);
    rentabilite = await FinanceService.getRentabilite(widget.user.code_expl);
    if (mounted) setState(() {});
  }

  // --- DESIGN : CARTE DE SOLDE ---
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

  // --- DESIGN : ACTIONS ---
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _btnAction("RECETTE", Icons.add_circle, Colors.green, () => _showTransactionDialog(false))),
            const SizedBox(width: 15),
            Expanded(child: _btnAction("DÉPENSE", Icons.remove_circle, Colors.redAccent, () => _showTransactionDialog(true))),
          ],
        ),
        const SizedBox(height: 15),
        // 🔴 BOUTON INTÉGRÉ POUR LE COMPTABLE (Accès à ses congés personnels)
        _btnAction(
            "DEMANDER / SUIVRE MES CONGÉS",
            Icons.beach_access_rounded,
            const Color(0xFF1B4332),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CongePage(user: widget.user),
                ),
              );
            }
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

  // --- DESIGN : MODAL ---
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
                  if (isDepense) {
                    await FinanceService.addDepense({"libelle": textCtrl.text, "montant": int.parse(montantCtrl.text), "code_expl": widget.user.code_expl});
                  } else {
                    await FinanceService.addRecette({"source": textCtrl.text, "montant": int.parse(montantCtrl.text), "code_expl": widget.user.code_expl});
                  }
                  Navigator.pop(context);
                  loadData();
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

  // --- DESIGN : HISTORIQUE ---
  Widget _buildHistorySection() {
    List items = [];
    if (filtre == "all" || filtre == "depense") items.addAll(depenses.map((e) => {...e, "type": "depense"}));
    if (filtre == "all" || filtre == "recette") items.addAll(recettes.map((e) => {...e, "type": "recette"}));

    items.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

    return Column(
      children: [
        Row(
          children: [
            const Text("Historique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              height: 40,
              child: Row(
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
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("Aucune transaction trouvée"),
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDep ? Colors.red[50] : Colors.green[50],
            child: Icon(isDep ? Icons.upload : Icons.download, color: isDep ? Colors.red : Colors.green, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDep ? item['libelle'] : item['source'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item['date'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            "${isDep ? '-' : '+'}${item['montant']} F",
            style: TextStyle(fontWeight: FontWeight.w900, color: isDep ? Colors.red : Colors.green, fontSize: 16),
          ),
        ],
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
        title: const Text("Finance", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPremiumBalanceCard(),
              const SizedBox(height: 25),
              _buildActionButtons(),
              const SizedBox(height: 35),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }
}