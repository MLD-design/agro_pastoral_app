import 'package:flutter/material.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';

class MyPersonnelPage extends StatefulWidget {
  @override
  _PersonnelPageState createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<MyPersonnelPage> {
  final service = PersonnelService();
  final exploitationService = ExploitationService();

  List<Personnel> list = [];
  List<Exploitation> exploitations = [];
  Exploitation? selected;

  final nom = TextEditingController();
  final poste = TextEditingController();
  final salaire = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadExploitations();
  }

  void loadExploitations() async {
    exploitations = await exploitationService.getAll();
    setState(() {});
  }

  void loadPersonnel() async {
    if (selected == null) return;
    setState(() => loading = true);
    final data = await service.getByExploitation(selected!.code_expl);
    setState(() {
      list = data;
      loading = false;
    });
  }

  // --- DESIGN : EN-TÊTE DE STATISTIQUES ---
  Widget _buildHeaderStats() {
    double totalSalaire = list.fold(0, (sum, item) => sum + item.salaire);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Effectif", "${list.length}", Icons.people_alt_rounded),
          Container(width: 1, height: 40, color: Colors.green.shade200),
          _statItem("Masse Salariale", "${totalSalaire.toStringAsFixed(0)} F", Icons.payments_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 20),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }

  // --- DESIGN : DIALOGUE D'AJOUT ---
  void showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25, right: 25, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Nouvelle Recrue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(nom, "Nom complet", Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(poste, "Poste occupé", Icons.work_outline),
            const SizedBox(height: 15),
            _buildTextField(salaire, "Salaire (FCFA)", Icons.money, isNumber: true),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  await addPersonnel();
                  Navigator.pop(context);
                },
                child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> addPersonnel() async {
    if (selected == null || nom.text.isEmpty) return;
    await service.add(Personnel(
      code_per: 0,
      nom: nom.text,
      poste: poste.text,
      salaire: double.parse(salaire.text),
      code_expl: selected!.code_expl,
    ));
    nom.clear(); poste.clear(); salaire.clear();
    loadPersonnel();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Personnel>> groupedByPoste = {};
    for (var p in list) {
      groupedByPoste.putIfAbsent(p.poste, () => []);
      groupedByPoste[p.poste]!.add(p);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Annuaire Personnel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        backgroundColor: Colors.green.shade800,
        label: const Text("AJOUTER", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Sélecteur d'exploitation stylisé
            DropdownButtonFormField<Exploitation>(
              decoration: InputDecoration(
                filled: true, fillColor: Colors.green.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.agriculture, color: Colors.green),
              ),
              hint: const Text("Choisir l'exploitation cible"),
              value: selected,
              items: exploitations.map((e) => DropdownMenuItem(value: e, child: Text(e.nom_expl))).toList(),
              onChanged: (v) {
                setState(() => selected = v);
                loadPersonnel();
              },
            ),
            const SizedBox(height: 20),

            if (selected != null && !loading) _buildHeaderStats(),

            const SizedBox(height: 20),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                children: groupedByPoste.entries.map((entry) {
                  return _buildPosteGroup(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.group_off_rounded, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 10),
        Text("Aucun personnel enregistré", style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildPosteGroup(String poste, List<Personnel> personnels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Container(width: 4, height: 20, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(poste.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85
          ),
          itemCount: personnels.length,
          itemBuilder: (context, i) {
            final p = personnels[i];
            return _buildEmployeeCard(p);
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(Personnel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade100,
            child: Text(p.nom[0].toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          ),
          const SizedBox(height: 12),
          Text(p.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Text("${p.salaire.toInt()} F", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}