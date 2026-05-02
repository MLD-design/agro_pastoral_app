import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/gestion-personnel/modelconge.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../services/gestion-personnel/servicesconge.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';

class CongePage extends StatefulWidget {
  @override
  _CongePageState createState() => _CongePageState();
}

class _CongePageState extends State<CongePage> with SingleTickerProviderStateMixin {
  final service = CongeService();
  List<Conge> conges = [];
  List<Exploitation> exploitations = [];
  Exploitation? selectedExpl;
  late TabController _tabController;

  final List<String> typesConge = ["Annuel", "Maternité", "Maladie"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadExploitations();
  }

  Future<void> loadExploitations() async {
    final expl = await ExploitationService().getAll();
    setState(() => exploitations = expl);
  }

  Future<void> loadConges() async {
    if (selectedExpl == null) return;
    final data = await service.getByExploitation(selectedExpl!.code_expl);
    setState(() => conges = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: const Text("Tableau des Congés", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTopHeader(),
          _buildExploitationPicker(),
          _buildCustomTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: typesConge.map((type) => _buildListView(type)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCongeSheet,
        backgroundColor: Colors.green.shade800,
        icon: const Icon(Icons.calendar_month), // Icône corrigée
        label: const Text("Nouvelle Demande"),
      ),
    );
  }

  Widget _buildTopHeader() {
    int pending = conges.where((c) => c.statut == "En attente").length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30)
        ),
      ),
      child: Column(
        children: [
          const Text("Statut Global", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerStatItem("${conges.length}", "Total"),
              _headerStatItem("$pending", "En attente", color: Colors.orangeAccent),
              _headerStatItem(
                  "${conges.where((c) => c.statut == "Validé").length}",
                  "Approuvés",
                  color: Colors.lightBlueAccent
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _headerStatItem(String value, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildExploitationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: DropdownButtonFormField<Exploitation>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.location_on, color: Colors.green),
        ),
        hint: const Text("Sélectionner l'exploitation"),
        value: selectedExpl,
        items: exploitations.map((e) => DropdownMenuItem(value: e, child: Text(e.nom_expl))).toList(),
        onChanged: (v) {
          setState(() => selectedExpl = v);
          loadConges();
        },
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(15)),
        labelColor: Colors.green.shade900,
        unselectedLabelColor: Colors.grey,
        tabs: typesConge.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildListView(String type) {
    final filtered = conges.where((c) => c.type == type).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text("Aucun dossier pour ce type"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildCongeCard(filtered[i]),
    );
  }

  Widget _buildCongeCard(Conge c) {
    Color statusColor = c.statut == "Validé" ? Colors.green : (c.statut == "Refusé" ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: statusColor, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text("Employé #${c.employeId}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.date_range, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text("${c.dateDebut} au ${c.dateFin}"),
              ],
            ),
            const SizedBox(height: 5),
            Text(c.statut, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: c.statut == "En attente"
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                onPressed: () async {
                  await service.updateStatut(c.id_conge, "Validé");
                  loadConges();
                }
            ),
            IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                onPressed: () async {
                  await service.updateStatut(c.id_conge, "Refusé");
                  loadConges();
                }
            ),
          ],
        )
            : Icon(Icons.verified_user, color: statusColor.withOpacity(0.3)),
      ),
    );
  }

  // --- LOGIQUE D'AJOUT ---

  void _showAddCongeSheet() {
    if (selectedExpl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez d'abord choisir une exploitation"))
      );
      return;
    }

    final debutCtrl = TextEditingController();
    final finCtrl = TextEditingController();
    String tempType = "Annuel";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder( // Important pour le changement du dropdown interne
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25, right: 25, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: SizedBox(width: 50, child: Divider(thickness: 4))),
                const SizedBox(height: 20),
                const Text("Nouvelle Demande", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),

                DropdownButtonFormField<String>(
                  value: tempType,
                  decoration: _sheetInputDecoration("Type de congé", Icons.category),
                  items: typesConge.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setSheetState(() => tempType = v!),
                ),
                const SizedBox(height: 15),

                _buildDateField(debutCtrl, "Date de début"),
                const SizedBox(height: 15),
                _buildDateField(finCtrl, "Date de fin"),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    onPressed: () async {
                      if(debutCtrl.text.isEmpty || finCtrl.text.isEmpty) return;

                      final newConge = Conge(
                        id_conge: DateTime.now().millisecondsSinceEpoch,
                        employeId: 101,
                        type: tempType,
                        dateDebut: debutCtrl.text,
                        dateFin: finCtrl.text,
                        statut: "En attente",
                        code_expl: selectedExpl!.code_expl,
                      );
                      await service.add(newConge);
                      await loadConges();
                      Navigator.pop(context);
                    },
                    child: const Text("SOUMETTRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: _sheetInputDecoration(label, Icons.calendar_today),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            ctrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
    );
  }

  InputDecoration _sheetInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}