import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/gestion-personnel/modelpaie.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../services/gestion-personnel/servicespaie.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';

class PaiementPage extends StatefulWidget {
  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final service = PaiementService();
  List<Paiement> paiements = [];
  List<Exploitation> exploitations = [];
  List<Personnel> personnels = [];
  Exploitation? selectedExpl;
  String selectedFilter = "Tous";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final expl = await ExploitationService().getAll();
    setState(() => exploitations = expl);
  }

  Future<void> loadPaiements() async {
    if (selectedExpl == null) return;
    final data = await service.getByExploitation(selectedExpl!.code_expl);
    final pers = await PersonnelService().getByExploitation(selectedExpl!.code_expl);
    setState(() {
      paiements = data;
      personnels = pers;
    });
  }

  // --- UI COMPONENTS ---

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green.shade700),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Paiement> filteredList = selectedFilter == "Tous"
        ? paiements
        : paiements.where((p) => p.statut == selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Paie & Salaires", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSelector(),
          if (selectedExpl != null) _buildQuickStats(),
          _buildFilterBar(),
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text("Aucune donnée disponible"))
                : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: filteredList.length,
              itemBuilder: (context, i) => _buildPaiementCard(filteredList[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaiementSheet,
        backgroundColor: Colors.green.shade800,
        icon: Icon(Icons.add),
        label: Text("Nouveau Paiement"),
      ),
    );
  }

  Widget _buildSelector() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: DropdownButtonFormField<Exploitation>(
        decoration: _inputStyle("Sélectionner l'exploitation", Icons.agriculture),
        value: selectedExpl,
        items: exploitations.map((e) => DropdownMenuItem(value: e, child: Text(e.nom_expl))).toList(),
        onChanged: (v) {
          setState(() => selectedExpl = v);
          loadPaiements();
        },
      ),
    );
  }

  Widget _buildQuickStats() {
    double total = paiements.where((p) => p.statut == "Payé").fold(0, (sum, p) => sum + p.net);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Total payé ce mois", style: TextStyle(color: Colors.white70)),
            Text("${total.toStringAsFixed(0)} FCFA", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          Icon(Icons.payments, color: Colors.white24, size: 40),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: ["Tous", "Payé", "En attente"].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f),
            selected: selectedFilter == f,
            onSelected: (s) => setState(() => selectedFilter = f),
            selectedColor: Colors.green.shade800,
            labelStyle: TextStyle(color: selectedFilter == f ? Colors.white : Colors.black),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPaiementCard(Paiement p) {
    bool isPaye = p.statut == "Payé";
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaye ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(isPaye ? Icons.check : Icons.hourglass_top, color: isPaye ? Colors.green : Colors.orange, size: 20),
        ),
        title: Text("Employé #${p.employeId}", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${p.mois} ${p.annee} • Net: ${p.net} F"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPaye) IconButton(icon: Icon(Icons.check_circle, color: Colors.green), onPressed: () async {
              await service.updateStatut(p.id_paiement, "Payé");
              loadPaiements();
            }),
            IconButton(icon: Icon(FontAwesomeIcons.filePdf, color: Colors.red, size: 18), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  // --- LOGIQUE ADD PAIEMENT ---

  void _showAddPaiementSheet() {
    if (selectedExpl == null) return;

    // 1. Déclaration des contrôleurs HORS du builder
    final moisCtrl = TextEditingController();
    final anneeCtrl = TextEditingController(text: DateTime.now().year.toString());
    final salaireBaseCtrl = TextEditingController();
    final primesCtrl = TextEditingController(text: "0");
    final retenuesCtrl = TextEditingController(text: "0");
    int? selectedEmpId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( // 2. StatefulBuilder interne
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 20),
                Text("Enregistrer un Salaire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 25),

                // Sélection employé
                DropdownButtonFormField<int>(
                  decoration: _inputStyle("Choisir l'employé", Icons.person),
                  items: personnels.map((p) => DropdownMenuItem(value: p.code_per, child: Text(p.nom))).toList(),
                  onChanged: (val) {
                    final emp = personnels.firstWhere((p) => p.code_per == val);
                    setSheetState(() { // Mise à jour locale à la BottomSheet
                      selectedEmpId = val;
                      // 🔵 REMPLISSAGE AUTO DU SALAIRE
                      salaireBaseCtrl.text = emp.salaire.toString();
                    });
                  },
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: TextField(controller: moisCtrl, decoration: _inputStyle("Mois", Icons.calendar_month))),
                    SizedBox(width: 10),
                    Expanded(child: TextField(controller: anneeCtrl, decoration: _inputStyle("Année", Icons.numbers), keyboardType: TextInputType.number)),
                  ],
                ),
                SizedBox(height: 15),

                TextField(controller: salaireBaseCtrl, decoration: _inputStyle("Salaire de base", Icons.payments), keyboardType: TextInputType.number),
                SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: TextField(controller: primesCtrl, decoration: _inputStyle("Primes", Icons.add_circle), keyboardType: TextInputType.number)),
                    SizedBox(width: 10),
                    Expanded(child: TextField(controller: retenuesCtrl, decoration: _inputStyle("Retenues", Icons.remove_circle), keyboardType: TextInputType.number)),
                  ],
                ),
                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () async {
                      if (selectedEmpId == null || salaireBaseCtrl.text.isEmpty) return;

                      final base = double.tryParse(salaireBaseCtrl.text) ?? 0;
                      final prm = double.tryParse(primesCtrl.text) ?? 0;
                      final ret = double.tryParse(retenuesCtrl.text) ?? 0;

                      final p = Paiement(
                        id_paiement: DateTime.now().millisecondsSinceEpoch,
                        employeId: selectedEmpId!,
                        code_expl: selectedExpl!.code_expl,
                        mois: moisCtrl.text,
                        annee: int.parse(anneeCtrl.text),
                        salaireBase: base,
                        primes: prm,
                        retenues: ret,
                        net: base + prm - ret,
                        statut: "En attente",
                      );

                      await service.create(p);
                      await loadPaiements();
                      Navigator.pop(context);
                    },
                    child: Text("VALIDER LE PAIEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}