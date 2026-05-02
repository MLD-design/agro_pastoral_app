import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../models/gestion-personnel/modelcontrat.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../services/gestion-personnel/servicescontrat.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../services/gestion-personnel/servicespdf.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';

class ContratPage extends StatefulWidget {
  @override
  _ContratPageState createState() => _ContratPageState();
}

class _ContratPageState extends State<ContratPage> {
  List<Exploitation> exploitations = [];
  List<Personnel> personnels = [];
  List<Contrat> contrats = [];

  Exploitation? selectedExpl;
  Personnel? selectedPers;
  String selectedFilter = "Tous"; // 🔹 Filtre actif
  String typeAdd = "CDD";

  final ContratService contratService = ContratService();
  final PdfService pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final expl = await ExploitationService().getAll();
    final pers = await PersonnelService().getAll();
    setState(() {
      exploitations = expl;
      personnels = pers;
    });
  }

  Future<void> loadContrats() async {
    if (selectedExpl == null) return;
    final data = await contratService.getByExploitation(selectedExpl!.code_expl);
    setState(() => contrats = data);
  }

  // 🔹 WIDGET : Barre de statistiques (KPIs)
  Widget _buildStatCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _statBox("Actifs", "${contrats.length}", Colors.blue),
          SizedBox(width: 15),
          _statBox("CDI", "${contrats.where((c) => c.type == 'CDI').length}", Colors.orange),
          SizedBox(width: 15),
          _statBox("Récent", "12h", Colors.green),
        ],
      ),
    );
  }

  Widget _statBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
        ]),
      ),
    );
  }

  // 🔹 WIDGET : Barre de Filtres Rapides
  Widget _buildFilterChips() {
    final filters = ["Tous", "CDD", "CDI", "Journalier"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = f),
              selectedColor: Colors.green.shade700,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Application du filtrage local
    List<Contrat> listToDisplay = selectedFilter == "Tous"
        ? contrats
        : contrats.where((c) => c.type == selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contrats de Travail", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade800,
        onPressed: _showAddBottomSheet,
        label: Text("GÉNÉRER CONTRAT", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Sélecteur Exploitation
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButtonFormField<Exploitation>(
              decoration: InputDecoration(
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.agriculture, color: Colors.green),
              ),
              hint: Text("Choisir l'exploitation"),
              value: selectedExpl,
              items: exploitations.map((e) => DropdownMenuItem(value: e, child: Text(e.nom_expl))).toList(),
              onChanged: (val) {
                setState(() => selectedExpl = val);
                loadContrats();
              },
            ),
          ),

          if (contrats.isNotEmpty) _buildStatCards(),
          _buildFilterChips(),
          SizedBox(height: 10),

          Expanded(
            child: listToDisplay.isEmpty
                ? Center(child: Text("Aucun contrat trouvé"))
                : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: listToDisplay.length,
              itemBuilder: (context, i) => _buildContractCard(listToDisplay[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard(Contrat c) {
    final url = "http://192.168.1.16:3000/${c.contratUrl}";
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: c.type == "CDI" ? Colors.blue.shade50 : Colors.orange.shade50,
          child: Icon(Icons.assignment, color: c.type == "CDI" ? Colors.blue : Colors.orange),
        ),
        title: Text("Contrat N°${c.id_contrat}", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Employé ID: ${c.employeId}\nType: ${c.type}"),
        trailing: Wrap(
          children: [
            IconButton(icon: Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () => launchUrl(Uri.parse(url))),
            IconButton(icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green), onPressed: () => _sharePdf(url, c.id_contrat)),
          ],
        ),
      ),
    );
  }

  // 🔹 BottomSheet d'ajout (plus moderne qu'un Dialog)
  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Création du Contrat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _dropdownPers(),
            SizedBox(height: 10),
            _dropdownType(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                onPressed: () async {
                  if (selectedPers == null) return;
                  final file = await pdfService.generateContratPdf(selectedPers!.nom, typeAdd);
                  await contratService.create(Contrat(
                    id_contrat: DateTime.now().millisecondsSinceEpoch,
                    employeId: selectedPers!.code_per,
                    code_expl: selectedExpl!.code_expl,
                    type: typeAdd,
                    dateDebut: DateTime.now().toString(),
                    dateFin: "",
                  ), file);
                  loadContrats();
                  Navigator.pop(context);
                },
                child: Text("GÉNÉRER LE PDF", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ... Méthodes de partage et dropdowns simplifiées ...
  Future<void> _sharePdf(String url, int id) async {
    final res = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/c_$id.pdf");
    await file.writeAsBytes(res.bodyBytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  Widget _dropdownPers() => DropdownButtonFormField<Personnel>(
    hint: Text("Choisir Personnel"),
    items: personnels.map((p) => DropdownMenuItem(value: p, child: Text(p.nom))).toList(),
    onChanged: (v) => setState(() => selectedPers = v),
  );

  Widget _dropdownType() => DropdownButtonFormField<String>(
    value: typeAdd,
    items: ["CDD", "CDI", "Journalier"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
    onChanged: (v) => setState(() => typeAdd = v!),
  );
}