import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/gestion-personnel/modelconge.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-personnel/servicesconge.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';

class CongePage extends StatefulWidget {
  final User user;
  const CongePage({super.key, required this.user});

  @override
  _CongePageState createState() => _CongePageState();
}

class _CongePageState extends State<CongePage> with SingleTickerProviderStateMixin {
  final service = CongeService();
  final personnelService = PersonnelService();
  List<Conge> conges = [];
  bool isLoading = true;
  late TabController _tabController;

  // Stockage pour le gestionnaire
  Map<int, String> _nomsEmployes = {};
  Map<int, String> _postesEmployes = {};

  final List<String> typesConge = ["Annuel", "Maternité", "Maladie"];
  bool get isgestionnaire => widget.user.role == "gestionnaire";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadConges();
  }

  Future<void> loadConges() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      List<Conge> data;
      if (isgestionnaire) {
        data = await service.getByExploitation(widget.user.code_expl, widget.user.token);
        final personnels = await personnelService.getAll();
        setState(() {
          _nomsEmployes = {for (var p in personnels) p.userId ?? 0: p.nom};
          _postesEmployes = {for (var p in personnels) p.userId ?? 0: p.poste};
        });
      } else {
        data = await service.getByEmploye(widget.user.id, widget.user.token);
      }
      if (mounted) setState(() { conges = data; isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B4332),
        title: const Text("SUIVI DES CONGÉS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(onPressed: loadConges, icon: const Icon(Icons.sync_rounded, color: Colors.white))],
      ),
      body: Column(
        children: [
          _buildTopHeader(),
          const SizedBox(height: 15),
          _buildCustomTabBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
                : TabBarView(controller: _tabController, children: typesConge.map((type) => _buildListView(type)).toList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCongeSheet, // 🔴 Appel de la fonction corrigée
        backgroundColor: const Color(0xFF1B4332),
        icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        label: const Text("NOUVEAU CONGÉ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTopHeader() {
    int pending = conges.where((c) => c.statut == "En attente").length;
    int approved = conges.where((c) => c.statut == "Validé").length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: const Color(0xFF1B4332).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _headerStatItem("${conges.length}", "Total", Colors.white),
          Container(height: 35, width: 1, color: Colors.white24),
          _headerStatItem("$pending", "En attente", Colors.orange),
          Container(height: 35, width: 1, color: Colors.white24),
          _headerStatItem("$approved", "Approuvés", Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _headerStatItem(String value, String label, Color color) => Column(children: [Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500))]);

  Widget _buildCustomTabBar() => Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]), child: TabBar(controller: _tabController, indicator: BoxDecoration(color: const Color(0xFF1B4332).withOpacity(0.08), borderRadius: BorderRadius.circular(14)), dividerColor: Colors.transparent, labelColor: const Color(0xFF1B4332), unselectedLabelColor: Colors.grey, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), tabs: typesConge.map((t) => Tab(text: t)).toList()));

  Widget _buildListView(String type) {
    final filtered = conges.where((c) => c.type == type).toList();
    if (filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_available_rounded, size: 65, color: const Color(0xFF1B4332).withOpacity(0.2)), const SizedBox(height: 15), Text("Aucun congé $type", style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 15))]));
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), itemCount: filtered.length, itemBuilder: (context, i) => _buildCongeCard(filtered[i]));
  }

  Widget _buildCongeCard(Conge c) {
    Color statusColor = c.statut == "Validé" ? Colors.green : (c.statut == "Refusé" ? Colors.red : Colors.orange);
    String titre = isgestionnaire ? (_nomsEmployes[c.employeId] ?? "Employé #${c.employeId}") : "Ma Demande";
    String poste = isgestionnaire ? (_postesEmployes[c.employeId] ?? "N/A") : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border(left: BorderSide(color: statusColor, width: 6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF081C15), fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            if (isgestionnaire) Text("Poste : ${poste.toUpperCase()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            const SizedBox(height: 3),
            Row(children: [const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey), const SizedBox(width: 8), Text("${c.dateDebut} — ${c.dateFin}", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))]),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(c.statut, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11))),
          ],
        ),
        trailing: isgestionnaire && c.statut == "En attente"
            ? Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32), onPressed: () async { await service.updateStatut(c.id_conge, "Validé", widget.user.token); loadConges(); }),
          IconButton(icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 32), onPressed: () async { await service.updateStatut(c.id_conge, "Refusé", widget.user.token); loadConges(); }),
        ])
            : Icon(c.statut == "Validé" ? Icons.check_circle_rounded : (c.statut == "Refusé" ? Icons.cancel_rounded : Icons.pending_rounded), color: statusColor.withOpacity(0.6), size: 26),
      ),
    );
  }

  // 🔴 FORMULAIRE DE DEMANDE (CORRIGÉ ET COMPLET)
  void _showAddCongeSheet() {
    final debutCtrl = TextEditingController();
    final finCtrl = TextEditingController();
    String tempType = "Annuel";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, left: 25, right: 25, top: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                const Text("Demande de Congé", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: tempType,
                  dropdownColor: Colors.white,
                  decoration: _sheetInputDecoration("Type de congé", Icons.category_outlined),
                  items: typesConge.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setSheetState(() => tempType = v!),
                ),
                const SizedBox(height: 15),
                _buildDateField(debutCtrl, "Date de début", context),
                const SizedBox(height: 15),
                _buildDateField(finCtrl, "Date de fin", context),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () async {
                      if (debutCtrl.text.isEmpty || finCtrl.text.isEmpty) return;
                      final n = Conge(id_conge: DateTime.now().millisecondsSinceEpoch, employeId: widget.user.id, type: tempType, dateDebut: debutCtrl.text, dateFin: finCtrl.text, statut: "En attente", code_expl: widget.user.code_expl);
                      await service.add(n, widget.user.token);
                      loadConges();
                      Navigator.pop(context);
                    },
                    child: const Text("SOUMETTRE LA DEMANDE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController ctrl, String label, BuildContext ctx) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: _sheetInputDecoration(label, Icons.calendar_today_outlined),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: ctx,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1B4332))), child: child!),
        );
        if (pickedDate != null) ctrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      },
    );
  }

  InputDecoration _sheetInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1B4332)),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    );
  }
}