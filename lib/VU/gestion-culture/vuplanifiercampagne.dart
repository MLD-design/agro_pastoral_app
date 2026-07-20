import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/gestion-culture/servicesparcelle.dart';
import '../../services/gestion-culture/servicescampagne.dart';
import '../../services/gestion-culture/servicessuivi.dart';
import '../../models/gestion-culture/modelparcelle.dart';
import '../../models/gestion-culture/modelcampagne.dart';
import '../../models/gestion-compte/modeluser.dart';
import 'vusuivresemi.dart';

class PlanificationPage extends StatefulWidget {
  final int code_expl;
  final User user;
  const PlanificationPage({super.key, required this.code_expl, required this.user});

  @override
  State<PlanificationPage> createState() => _PlanificationPageState();
}

class _PlanificationPageState extends State<PlanificationPage> {
  final ParcelleService parcelleService = ParcelleService();
  final CampagneService campagneService = CampagneService();
  final SuiviService suiviService = SuiviService();

  List<Parcelle> parcelles = [];
  List<Campagne> campagnes = [];
  int? selectedParcelle;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  DateTime? selectedEndDate; // Nouvelle propriété pour l'échéance de récolte
  final nomController = TextEditingController();
  Map<DateTime, List<Campagne>> events = {};
  bool isLoading = false;

  final Color primaryGreen = const Color(0xFF1B4332);
  final Color accentGreen = const Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    loadParcelles();
  }

  void loadParcelles() async {
    final data = await parcelleService.getByExploitation(widget.code_expl, widget.user.token);
    setState(() => parcelles = data);
  }

  void loadCampagnes(int id_cham) async {
    setState(() => isLoading = true);
    final data = await campagneService.getByParcelle(id_cham, widget.user.token);
    Map<DateTime, List<Campagne>> temp = {};
    for (var c in data) {
      DateTime date = DateTime.parse(c.date_debut);
      DateTime key = DateTime(date.year, date.month, date.day);
      temp.putIfAbsent(key, () => []).add(c);
    }
    setState(() {
      campagnes = data;
      events = temp;
      isLoading = false;
    });
  }

  // Permet de mapper la couleur renvoyée par le backend aux widgets Flutter
  Color _getAlertColor(String statusCouleur) {
    switch (statusCouleur) {
      case 'ROUGE':
        return Colors.redAccent;
      case 'ORANGE':
        return Colors.orangeAccent;
      default:
        return accentGreen;
    }
  }

  // Sélecteur de date pour l'échéance de fin (Récolte prévisionnelle)
  void _choisirDateFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: selectedDay ?? DateTime.now(),
      lastDate: DateTime.utc(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedEndDate = picked);
    }
  }

  void saveCampagne() async {
    if (nomController.text.isEmpty || selectedDay == null) return;

    if (selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une date prévisionnelle de récolte.")),
      );
      return;
    }

    final camp = Campagne(
      id_camp: 0,
      nom_camp: nomController.text.trim(),
      date_debut: selectedDay!.toIso8601String(),
      date_fin: selectedEndDate!.toIso8601String(), // Date de fin réelle choisie
      code_expl: widget.code_expl,
      id_cham: selectedParcelle!,
      statut: "Planifié",
      etape_actuelle: "Semis",
      quantite_recoltee: 0.0,
      status_couleur: "VERT",
    );

    final campagneCreee = await campagneService.create(camp, widget.user.token);

    // Le suivi est un module séparé : on l'initialise explicitement ici,
    // juste après la planification, pour que l'expérience reste la même
    // qu'avant (suivi prêt dès la création de la campagne).
    await suiviService.create(
      selectedParcelle!.toString(),
      campagneCreee.id_camp.toString(),
      widget.user.token,
      dateFin: campagneCreee.date_fin,
    );

    loadCampagnes(selectedParcelle!);
    nomController.clear();
    setState(() => selectedEndDate = null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Campagne planifiée et suivi activé !"),
          backgroundColor: Color(0xFF2D6A4F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Campagne> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Planification", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Choisir une parcelle"),
            _buildParcelleSelector(),

            const SizedBox(height: 25),
            _buildCalendarCard(),

            if (selectedDay != null && selectedParcelle != null) ...[
              const SizedBox(height: 25),
              _buildAddCampagneForm(),
            ],

            const SizedBox(height: 30),
            _buildSectionTitle("Campagnes du jour"),
            _buildDailyList(),

            const SizedBox(height: 30),
            _buildSectionTitle("Historique de la parcelle"),
            isLoading
                ? Center(child: CircularProgressIndicator(color: primaryGreen))
                : _buildFullList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
    );
  }

  Widget _buildParcelleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedParcelle,
          hint: const Text("Quelle terre souhaitez-vous cultiver ?"),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen),
          items: parcelles.map((p) => DropdownMenuItem(value: p.id_cham, child: Text(p.nom_cham))).toList(),
          onChanged: (value) {
            setState(() => selectedParcelle = value);
            if (value != null) loadCampagnes(value);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024),
        lastDay: DateTime.utc(2030),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) => setState(() { selectedDay = selected; focusedDay = focused; }),
        eventLoader: getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAddCampagneForm() {
    String txtDateFin = selectedEndDate == null
        ? "Sélectionner la date de récolte estimée"
        : "Récolte : ${selectedEndDate!.toLocal().toString().split(' ')[0]}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryGreen.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextField(
            controller: nomController,
            decoration: InputDecoration(
              hintText: "Ex: Culture de Maïs Printemps",
              filled: true,
              fillColor: const Color(0xFFF3F7F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.grass, color: primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton d'ouverture du DatePicker pour la fin de campagne
          OutlinedButton.icon(
            onPressed: _choisirDateFin,
            icon: Icon(Icons.calendar_month, color: accentGreen),
            label: Text(txtDateFin, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              side: BorderSide(color: primaryGreen.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: saveCampagne,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("PLANIFIER LA CAMPAGNE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyList() {
    final daily = selectedDay != null ? getEventsForDay(selectedDay!) : [];
    if (daily.isEmpty) return const Text("Aucune campagne prévue à cette date.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));

    return Column(
      children: daily.map((c) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: _getAlertColor(c.status_couleur).withOpacity(0.1),
              child: Icon(Icons.eco, color: _getAlertColor(c.status_couleur), size: 20)
          ),
          title: Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Échéance récolte : ${c.date_fin.split('T')[0]}"),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () => _ouvrirSuivi(c),
        ),
      )).toList(),
    );
  }

  void _ouvrirSuivi(Campagne c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuiviPage(
          idCham: c.id_cham,
          idCamp: c.id_camp,
          nomCampagne: c.nom_camp,
          user: widget.user,
        ),
      ),
    );
  }

  Widget _buildFullList() {
    if (campagnes.isEmpty) return const SizedBox();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campagnes.length,
      itemBuilder: (context, index) {
        final c = campagnes[index];
        Color badgeColor = _getAlertColor(c.status_couleur);

        return InkWell(
          onTap: () => _ouvrirSuivi(c),
          borderRadius: BorderRadius.circular(20),
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
          ),
          child: Row(
            children: [
              Container(
                width: 4, height: 40,
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                          child: Text(c.statut.toUpperCase(), style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Étape: ${c.etape_actuelle}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(height: 4),
                  Text(c.date_debut.split('T')[0], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}