import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/gestion-personnel/modelpaie.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-personnel/servicespaie.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';

class PaiementPage extends StatefulWidget {
  final User user;

  const PaiementPage({super.key, required this.user});

  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final service = PaiementService();
  List<Paiement> paiements = [];
  List<Personnel> personnels = [];
  bool isLoading = true;
  String selectedFilter = "Tous";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final data = await service.getByExploitation(widget.user.code_expl, widget.user.token);
    final pers = await PersonnelService().getByExploitation(widget.user.code_expl, widget.user.token);
    if (mounted) {
      setState(() {
        paiements = data;
        personnels = pers;
        isLoading = false;
      });
    }
  }

  // Nom affiché : priorité au nom stocké sur le paiement lui-même (fiable,
  // même si l'employé est renommé ou supprimé plus tard), sinon on retombe
  // sur la liste actuelle du personnel.
  String _nomEmploye(Paiement p) {
    if (p.employeNom != null && p.employeNom!.isNotEmpty) return p.employeNom!;
    final match = personnels.where((pers) => pers.code_per == p.employeId);
    return match.isNotEmpty ? match.first.nom : "Employé inconnu";
  }

  Future<void> _genererEtOuvrirBulletin(Paiement p) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    String? url = await service.generateBulletin(p);

    if (url != null) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final String savePath = "${dir.path}/bulletin_${p.id_paiement}.pdf";

        final response = await Dio().download(url, savePath);
        if (response.statusCode != 200) {
          throw Exception("Téléchargement échoué (code ${response.statusCode}) — vérifiez que '/uploads' est bien servi statiquement par votre serveur Express.");
        }

        // Vérification que le fichier téléchargé est bien un PDF valide et
        // pas une page d'erreur HTML sauvegardée sous le mauvais nom.
        final bytes = await File(savePath).readAsBytes();
        final entete = bytes.length > 4 ? String.fromCharCodes(bytes.take(4)) : '';
        if (entete != '%PDF') {
          throw Exception("Le fichier téléchargé n'est pas un PDF valide (probablement une erreur serveur renvoyée à la place du bulletin).");
        }

        final result = await OpenFilex.open(savePath);
        if (result.type != ResultType.done) {
          throw Exception("${result.message} (type: ${result.type})");
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'ouverture : $e")));
        }
      }
    } else {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur de génération du bulletin")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Paiement> filteredList = selectedFilter == "Tous"
        ? paiements
        : paiements.where((p) => p.statut == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Paie & Salaires", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
                : filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredList.length,
              itemBuilder: (context, i) => _buildPaiementCard(filteredList[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaiementSheet,
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NOUVEAU PAIEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildQuickStats() {
    double total = paiements.where((p) => p.statut == "Payé").fold(0, (sum, p) => sum + p.net);
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Total décaissé (Payé)", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 5),
            Text("${total.toInt()} FCFA", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.account_balance_wallet, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: ["Tous", "Payé", "En attente"].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f),
            selected: selectedFilter == f,
            onSelected: (s) => setState(() => selectedFilter = f),
            selectedColor: const Color(0xFF1B5E20),
            labelStyle: TextStyle(color: selectedFilter == f ? Colors.white : Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPaiementCard(Paiement p) {
    bool isPaye = p.statut == "Payé";
    String empNom = _nomEmploye(p);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPaye ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(isPaye ? Icons.verified : Icons.history_toggle_off, color: isPaye ? Colors.green : Colors.orange, size: 20),
        ),
        title: Text(empNom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${p.mois} ${p.annee} • Net: ${p.net.toInt()} F"
          "${p.primes.isNotEmpty || p.retenues.isNotEmpty ? ' (${p.primes.length} prime${p.primes.length > 1 ? 's' : ''}, ${p.retenues.length} retenue${p.retenues.length > 1 ? 's' : ''})' : ''}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPaye)
              IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () async {
                    await service.updateStatut(p.id_paiement, "Payé", widget.user.token);
                    loadData();
                  }
              ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.filePdf, color: Colors.redAccent, size: 18),
              onPressed: () => _genererEtOuvrirBulletin(p),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaiementSheet() {
    final moisCtrl = TextEditingController(text: _getCurrentMonth());
    final anneeCtrl = TextEditingController(text: DateTime.now().year.toString());
    final salaireBaseCtrl = TextEditingController();
    final posteCtrl = TextEditingController();
    int? selectedEmpId;
    String? selectedEmpNom;

    // Primes et retenues sont désormais des listes détaillées, ajoutables
    // dynamiquement (ex: "Prime de transport" -> 15000), au lieu d'un
    // simple total — c'est ce qui rend le bulletin final "plein d'arguments".
    List<Map<String, TextEditingController>> primesCtrls = [];
    List<Map<String, TextEditingController>> retenuesCtrls = [];
    double netAffiche = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          void updateNet() {
            double base = double.tryParse(salaireBaseCtrl.text) ?? 0;
            double prm = primesCtrls.fold(0.0, (s, c) => s + (double.tryParse(c['montant']!.text) ?? 0));
            double ret = retenuesCtrls.fold(0.0, (s, c) => s + (double.tryParse(c['montant']!.text) ?? 0));
            setSheetState(() => netAffiche = base + prm - ret);
          }

          Widget buildLignesEditor(String titre, List<Map<String, TextEditingController>> lignes, IconData icon, Color couleur) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () => setSheetState(() {
                        lignes.add({"libelle": TextEditingController(), "montant": TextEditingController()});
                      }),
                      icon: Icon(icon, size: 16, color: couleur),
                      label: Text("Ajouter", style: TextStyle(color: couleur, fontSize: 12)),
                    ),
                  ],
                ),
                ...lignes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ctrls = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: ctrls['libelle'],
                            decoration: _inputStyle("Libellé", Icons.label_outline),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: ctrls['montant'],
                            keyboardType: TextInputType.number,
                            onChanged: (_) => updateNet(),
                            decoration: _inputStyle("Montant", Icons.payments_outlined),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                          onPressed: () => setSheetState(() { lignes.removeAt(i); updateNet(); }),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }

          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  const Text("Établir un Bulletin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  DropdownButtonFormField<int>(
                    decoration: _inputStyle("Choisir l'employé", Icons.person_search),
                    items: personnels.map((p) => DropdownMenuItem(value: p.code_per, child: Text(p.nom))).toList(),
                    onChanged: (val) {
                      final emp = personnels.firstWhere((p) => p.code_per == val);
                      setSheetState(() {
                        selectedEmpId = val;
                        selectedEmpNom = emp.nom;
                        salaireBaseCtrl.text = emp.salaire.toString();
                        updateNet();
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: posteCtrl, decoration: _inputStyle("Fonction / Poste (optionnel)", Icons.badge_outlined)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: moisCtrl, decoration: _inputStyle("Mois", Icons.calendar_today))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: anneeCtrl, decoration: _inputStyle("Année", Icons.numbers), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: salaireBaseCtrl, onChanged: (_) => updateNet(), decoration: _inputStyle("Salaire de base", Icons.payments), keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  buildLignesEditor("Primes", primesCtrls, Icons.add_circle_outline, const Color(0xFF1B5E20)),
                  const SizedBox(height: 15),
                  buildLignesEditor("Retenues", retenuesCtrls, Icons.remove_circle_outline, Colors.redAccent),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("NET À PAYER :", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${netAffiche.toInt()} FCFA", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1B5E20), fontSize: 18)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () async {
                        if (selectedEmpId == null || salaireBaseCtrl.text.isEmpty) return;

                        final primes = primesCtrls
                            .where((c) => c['libelle']!.text.trim().isNotEmpty && double.tryParse(c['montant']!.text) != null)
                            .map((c) => LignePaie(libelle: c['libelle']!.text.trim(), montant: double.parse(c['montant']!.text)))
                            .toList();
                        final retenues = retenuesCtrls
                            .where((c) => c['libelle']!.text.trim().isNotEmpty && double.tryParse(c['montant']!.text) != null)
                            .map((c) => LignePaie(libelle: c['libelle']!.text.trim(), montant: double.parse(c['montant']!.text)))
                            .toList();

                        final p = Paiement(
                          id_paiement: 0, // ignoré à la création : le backend génère le vrai id
                          employeId: selectedEmpId!,
                          employeNom: selectedEmpNom,
                          employePoste: posteCtrl.text.trim().isEmpty ? null : posteCtrl.text.trim(),
                          code_expl: widget.user.code_expl,
                          mois: moisCtrl.text,
                          annee: int.parse(anneeCtrl.text),
                          salaireBase: double.parse(salaireBaseCtrl.text),
                          primes: primes,
                          retenues: retenues,
                          statut: "En attente",
                        );
                        await service.create(p, widget.user.token);
                        loadData();
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text("VALIDER LE PAIEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  String _getCurrentMonth() {
    List months = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"];
    return months[DateTime.now().month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text("Aucun historique de paiement", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
