import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../models/gestion-personnel/modelcontrat.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../services/gestion-personnel/servicescontrat.dart';
import '../../services/gestion-personnel/servicespdf.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';

class ContratPage extends StatefulWidget {
  final User user;

  const ContratPage({super.key, required this.user});

  @override
  _ContratPageState createState() => _ContratPageState();
}

class _ContratPageState extends State<ContratPage> {
  final ContratService contratService = ContratService();
  final PdfService pdfService = PdfService();

  List<Personnel> personnels = [];
  List<Contrat> contrats = [];
  bool isLoading = true;

  Personnel? selectedPers;
  String selectedFilter = "Tous";
  String typeAdd = "CDD";

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final pers = await PersonnelService().getByExploitation(widget.user.code_expl, widget.user.token);
      final data = await contratService.getByExploitation(widget.user.code_expl, widget.user.token);

      if (mounted) {
        setState(() {
          personnels = pers;
          contrats = data;
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

  @override
  Widget build(BuildContext context) {
    List<Contrat> listToDisplay = selectedFilter == "Tous"
        ? contrats
        : contrats.where((c) => c.type == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2), // Même fond que le dashboard
      appBar: AppBar(
        title: const Text(
            "CONTRATS DE TRAVAIL",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16, color: Colors.white)
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B4332), // Vert Sapin Dashboard
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: loadInitialData, icon: const Icon(Icons.sync_rounded, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          _buildTopSummary(),
          const SizedBox(height: 15),
          _buildFilterChips(),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
                : listToDisplay.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listToDisplay.length,
              itemBuilder: (context, i) => _buildContractCard(listToDisplay[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B4332),
        onPressed: _showAddBottomSheet,
        label: const Text("GÉNÉRER CONTRAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- TOP SUMMARY EN DÉGRADÉ ---
  Widget _buildTopSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30)
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          _statTile("Total", "${contrats.length}", Colors.white),
          Container(height: 35, width: 1, color: Colors.white24),
          _statTile("CDI", "${contrats.where((c) => c.type == 'CDI').length}", Colors.blueAccent),
          Container(height: 35, width: 1, color: Colors.white24),
          _statTile("CDD", "${contrats.where((c) => c.type == 'CDD').length}", Colors.orange),
        ],
      ),
    );
  }

  Widget _statTile(String label, String val, Color color) {
    return Expanded(
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5)),
      ]),
    );
  }

  // --- CHIPS FILTRES HARMONISÉS ---
  Widget _buildFilterChips() {
    final filters = ["Tous", "CDD", "CDI", "Journalier"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = f),
              selectedColor: const Color(0xFF1B4332),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1B4332),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
              side: BorderSide(color: const Color(0xFF1B4332).withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- CARTES DE CONTRATS HARMONISÉES ---
  Widget _buildContractCard(Contrat c) {
    final String url = "http://192.168.200.18:3000/${c.contratUrl}";
    String nomEmp = personnels.any((p) => p.code_per == c.employeId)
        ? personnels.firstWhere((p) => p.code_per == c.employeId).nom
        : "Employé #${c.employeId}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
              color: (c.type == "CDI" ? Colors.blue : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15)
          ),
          child: Icon(Icons.description_rounded, color: c.type == "CDI" ? Colors.blue : Colors.orange, size: 24),
        ),
        title: Text(nomEmp, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF081C15), fontSize: 16)),
        subtitle: Text("Contrat N°${c.id_contrat} • ${c.type}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
              onPressed: () => launchUrl(Uri.parse(url)),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
              onPressed: () => _sharePdf(url, c.id_contrat),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL DE SAISIE HARMONISÉ ---
  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              left: 25, right: 25, top: 15
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Nouveau Contrat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
              const SizedBox(height: 25),

              DropdownButtonFormField<Personnel>(
                decoration: _inputStyle("Choisir l'employé", Icons.person_rounded),
                dropdownColor: Colors.white,
                items: personnels.map((p) => DropdownMenuItem(value: p, child: Text(p.nom))).toList(),
                onChanged: (v) => setState(() => selectedPers = v),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: typeAdd,
                decoration: _inputStyle("Type de contrat", Icons.assignment_turned_in_rounded),
                dropdownColor: Colors.white,
                items: ["CDD", "CDI", "Journalier"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => typeAdd = v!),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (selectedPers == null) return;

                    final file = await pdfService.generateContratPdf(selectedPers!.nom, typeAdd);

                    await contratService.create(Contrat(
                      id_contrat: DateTime.now().millisecondsSinceEpoch,
                      employeId: selectedPers!.code_per,
                      code_expl: widget.user.code_expl,
                      type: typeAdd,
                      dateDebut: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      dateFin: "",
                    ), file, widget.user.token);

                    loadInitialData();
                    Navigator.pop(context);
                  },
                  child: const Text("GÉNÉRER & ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1B4332)),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      floatingLabelStyle: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
    );
  }

  Future<void> _sharePdf(String url, int id) async {
    try {
      final res = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/contrat_$id.pdf");
      await file.writeAsBytes(res.bodyBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Contrat de travail');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de partage : $e")));
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 70, color: const Color(0xFF1B4332).withOpacity(0.2)),
          const SizedBox(height: 15),
          const Text("Aucun contrat pour cette catégorie", style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}