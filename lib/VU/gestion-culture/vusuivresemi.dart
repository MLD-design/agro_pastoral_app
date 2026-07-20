// lib/VU/gestion-culture/vusuivicampagne.dart
import 'package:flutter/material.dart';
import '../../services/gestion-culture/servicessuivi.dart';
import '../../models/gestion-culture/modelsuivisemi.dart';
import '../../models/gestion-compte/modeluser.dart';

class SuiviPage extends StatefulWidget {
  final int idCham;
  final int idCamp;
  final String nomCampagne;
  final User user;

  const SuiviPage({
    super.key, required this.idCham, required this.idCamp,
    required this.nomCampagne, required this.user,
  });

  @override
  State<SuiviPage> createState() => _SuiviCampagnePageState();
}

class _SuiviCampagnePageState extends State<SuiviPage> {
  final service = SuiviService();
  PhaseSuiviModel? suivi;
  bool isLoading = true;

  // Palette principale Pro (SaaS industriel)
  final Color primaryGreen = const Color(0xFF0F3021);
  final Color accentGreen = const Color(0xFF1B4332);
  final Color softBackground = const Color(0xFFF4F7F6);

  // Codes couleurs fonctionnels par type d'action
  final Color colorJalon = const Color(0xFF2E7D32);       // Vert - Succès / Validation
  final Color colorObservation = const Color(0xFF1565C0); // Bleu - Information
  final Color colorRecolte = const Color(0xFF6D4C41);     // Brun - Récolte / Terre
  final Color colorTraitement = const Color(0xFFE65100);  // Orange - Traitement / Alerte

  @override
  void initState() {
    super.initState();
    loadSuivi();
  }

  Future<void> loadSuivi() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final raw = await service.get(widget.idCham.toString(), widget.idCamp.toString(), widget.user.token);
      if (mounted) setState(() { suivi = PhaseSuiviModel.fromJson(raw); isLoading = false; });
    } catch (e) {
      try {
        final raw = await service.create(widget.idCham.toString(), widget.idCamp.toString(), widget.user.token);
        if (mounted) setState(() { suivi = PhaseSuiviModel.fromJson(raw); isLoading = false; });
      } catch (e2) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de synchronisation : $e2")));
        }
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== DIALOGUES ET FORMULAIRES FONCTIONNELS =====================

  Future<void> _ouvrirFormulaireSemis() async {
    final varieteController = TextEditingController();
    final quantiteController = TextEditingController();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Valider le semis"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: varieteController,
              decoration: const InputDecoration(labelText: "Variété semée", hintText: "Ex : Maïs hybride H1"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantiteController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Quantité semée (kg)", hintText: "Ex : 25"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: colorJalon, foregroundColor: Colors.white),
            child: const Text("Valider"),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    final erreur = await service.validerEtape(
      widget.idCham.toString(), widget.idCamp.toString(), "semis",
      {
        "variete": varieteController.text.trim(),
        "quantite_semee": double.tryParse(quantiteController.text.trim()) ?? 0,
      },
      widget.user.token,
    );

    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  Future<void> _ouvrirFormulaireLevee() async {
    final tauxController = TextEditingController();
    final noteController = TextEditingController();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Valider la levée"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tauxController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Taux de levée (%)", hintText: "Ex : 90"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Remarque (optionnel)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: colorJalon, foregroundColor: Colors.white),
            child: const Text("Valider"),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    final erreur = await service.validerEtape(
      widget.idCham.toString(), widget.idCamp.toString(), "levee",
      {
        "taux_levee": double.tryParse(tauxController.text.trim()) ?? 0,
        "note": noteController.text.trim(),
      },
      widget.user.token,
    );

    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  Future<void> _ouvrirFormulaireObservation() async {
    final noteController = TextEditingController();
    final stadeController = TextEditingController();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle observation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stadeController,
              decoration: const InputDecoration(labelText: "Stade / hauteur (optionnel)", hintText: "Ex : 40 cm, stade 4 feuilles"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Observation", hintText: "Ex : bon développement, pas de stress hydrique"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: colorObservation, foregroundColor: Colors.white),
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );

    if (confirme != true || noteController.text.trim().isEmpty) return;

    final erreur = await service.ajouterObservation(
      widget.idCham.toString(), widget.idCamp.toString(),
      noteController.text.trim(),
      {"stade": stadeController.text.trim()},
      widget.user.token,
    );

    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  Future<void> _ouvrirFormulaireRecolte() async {
    final quantiteController = TextEditingController();
    final noteController = TextEditingController();
    String unite = 'kg';
    String qualite = 'Bonne';

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(suivi!.recolte.passages.isEmpty ? "Première récolte" : "Nouvelle récolte"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantiteController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: "Quantité récoltée"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: unite,
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'tonnes', child: Text('tonnes')),
                          DropdownMenuItem(value: 'sacs', child: Text('sacs')),
                        ],
                        onChanged: (v) => setDialogState(() => unite = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: qualite,
                  decoration: const InputDecoration(labelText: "Qualité"),
                  items: const [
                    DropdownMenuItem(value: 'Bonne', child: Text('Bonne')),
                    DropdownMenuItem(value: 'Moyenne', child: Text('Moyenne')),
                    DropdownMenuItem(value: 'Faible', child: Text('Faible')),
                  ],
                  onChanged: (v) => setDialogState(() => qualite = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Remarque (optionnel)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: colorRecolte, foregroundColor: Colors.white),
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );

    if (confirme != true) return;
    final quantite = double.tryParse(quantiteController.text.trim());
    if (quantite == null || quantite <= 0) {
      _showError("Merci de saisir une quantité valide.");
      return;
    }

    final erreur = await service.ajouterPassageRecolte(
      widget.idCham.toString(), widget.idCamp.toString(),
      quantite, unite, qualite, noteController.text.trim(),
      widget.user.token,
    );

    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  Future<void> _confirmerClotureRecolte() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clôturer la récolte"),
        content: Text(
          "Total récolté : ${suivi!.recolte.totalRecolte.toStringAsFixed(1)} ${suivi!.recolte.passages.isNotEmpty ? suivi!.recolte.passages.last.unite : 'units'}.\n"
              "Une fois clôturée, aucun nouveau passage ne pourra être ajouté. Confirmer ?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            child: const Text("Clôturer"),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final erreur = await service.cloturerRecolte(widget.idCham.toString(), widget.idCamp.toString(), widget.user.token);
    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  Future<void> _ouvrirFormulaireTraitement() async {
    final descController = TextEditingController();
    String phaseChoisie = 'Semis';

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Nouveau traitement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Ex : traitement fongicide suite à taches sur les feuilles",
                ),
              ),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: Text("Effectué pendant :", style: TextStyle(fontWeight: FontWeight.bold))),
              RadioListTile<String>(
                title: const Text("La phase de semis"),
                value: 'Semis',
                groupValue: phaseChoisie,
                onChanged: (v) => setDialogState(() => phaseChoisie = v!),
              ),
              RadioListTile<String>(
                title: const Text("La phase de récolte"),
                value: 'Recolte',
                groupValue: phaseChoisie,
                onChanged: (v) => setDialogState(() => phaseChoisie = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: colorTraitement, foregroundColor: Colors.white),
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );

    if (confirme != true || descController.text.trim().isEmpty) return;

    final erreur = await service.ajouterTraitement(
      widget.idCham.toString(), widget.idCamp.toString(),
      descController.text.trim(), phaseChoisie, {}, widget.user.token,
    );

    if (!mounted) return;
    if (erreur != null) _showError(erreur); else loadSuivi();
  }

  // ===================== CONTEXTUELS ET DESIGN WIDGETS =====================

  @override
  Widget build(BuildContext context) {
    final bool semisValide = suivi?.semis.semis.completed ?? false;
    final bool leveeValidee = suivi?.semis.levee.completed ?? false;
    final bool recolteCloturee = suivi?.recolte.cloturee ?? false;

    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.5),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SUIVI DE CAMPAGNE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white70)),
            const SizedBox(height: 2),
            Text(widget.nomCampagne, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : suivi == null
          ? const Center(child: Text("Aucun suivi disponible"))
          : RefreshIndicator(
        onRefresh: loadSuivi,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // SECTION : JALONS
            _buildSection("Jalons de cycle", [
              _buildJalonCard("Semis", Icons.grass_rounded, suivi!.semis.semis, _ouvrirFormulaireSemis),
              _buildJalonCard("Levée", Icons.eco_rounded, suivi!.semis.levee, semisValide ? _ouvrirFormulaireLevee : null),
            ]),

            // SECTION : OBSERVATIONS
            _buildSection("Observations de croissance", [
              if (suivi!.semis.observations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Aucune observation enregistrée.", style: TextStyle(color: Colors.black45, fontSize: 13,   fontStyle: FontStyle.italic)),
                ),
              ...suivi!.semis.observations.reversed.map((o) {
                final String stade = (o.data?['stade'] != null && o.data!['stade'].toString().isNotEmpty) ? "${o.data!['stade']} · " : "";
                return _buildItemCard(Icons.visibility_outlined, o.note, "$stade${o.date.split('T')[0]}", colorObservation);
              }),
              if (semisValide)
                _buildActionTile("Ajouter une observation", Icons.add_comment_rounded, _ouvrirFormulaireObservation, colorObservation),
            ]),

            // SECTION : RÉCOLTES
            _buildSection("Suivi de Récolte", [
              if (recolteCloturee)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: colorRecolte.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: colorRecolte.withOpacity(0.3))),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded, color: colorRecolte, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Récolte clôturée · Total : ${suivi!.recolte.totalRecolte.toStringAsFixed(1)} ${suivi!.recolte.passages.isNotEmpty ? suivi!.recolte.passages.last.unite : ''}",
                          style: TextStyle(color: colorRecolte, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!leveeValidee)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text("La récolte sera disponible après validation de la levée.", style: TextStyle(color: Colors.black45, fontSize: 13, fontStyle: FontStyle.italic)),
                ),
              ...suivi!.recolte.passages.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final title = idx == 0 ? "Première récolte — ${p.quantite} ${p.unite}" : "Récolte n°${idx + 1} — ${p.quantite} ${p.unite}";
                final subtitle = [if (p.qualite != null) "Qualité: ${p.qualite}", p.date.split('T')[0], if (p.note != null && p.note!.isNotEmpty) p.note].join(' · ');
                return _buildItemCard(Icons.agriculture_rounded, title, subtitle, colorRecolte);
              }),
              if (leveeValidee && !recolteCloturee) ...[
                _buildActionTile("Nouvelle récolte (passage)", Icons.add_box_rounded, _ouvrirFormulaireRecolte, colorRecolte),
                if (suivi!.recolte.passages.isNotEmpty)
                  _buildActionTile("Clôturer définitivement la récolte", Icons.lock_outline_rounded, _confirmerClotureRecolte, Colors.red.shade800),
              ]
            ]),

            // SECTION : TRAITEMENTS
            _buildSection("Traitements & Protections", [
              if (suivi!.traitements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Aucun traitement enregistré.", style: TextStyle(color: Colors.black45, fontSize: 13, fontStyle: FontStyle.italic)),
                ),
              ...suivi!.traitements.map((t) => _buildItemCard(Icons.science_outlined, t.description, "Phase : ${t.phase} · ${t.date.split('T')[0]}", colorTraitement)),
              if (semisValide)
                _buildActionTile("Ajouter un traitement effectué", Icons.healing_rounded, _ouvrirFormulaireTraitement, colorTraitement),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 12),
        child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryGreen.withOpacity(0.6), letterSpacing: 1.3)),
      ),
      ...children,
      const SizedBox(height: 16),
    ],
  );

  Widget _buildJalonCard(String titre, IconData icon, StepModel step, VoidCallback? action) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: step.completed ? colorJalon.withOpacity(0.1) : softBackground, borderRadius: BorderRadius.circular(14)),
          child: Icon(step.completed ? Icons.check_circle_rounded : icon, color: step.completed ? colorJalon : primaryGreen.withOpacity(0.4)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: step.completed ? colorJalon : Colors.black87)),
              const SizedBox(height: 2),
              Text(step.completed ? "Validé le ${step.date?.split('T')[0]}" : (action == null ? "Bloqué" : "En attente"), style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
        ),
        if (!step.completed && action != null)
          ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorJalon,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Valider", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
      ],
    ),
  );

  Widget _buildItemCard(IconData icon, String title, String subtitle, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.15), width: 1),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5))),
      ),
    ),
  );

  Widget _buildActionTile(String label, IconData icon, VoidCallback action, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: ListTile(
      onTap: action,
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
    ),
  );
}