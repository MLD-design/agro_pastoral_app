import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/gestion-culture/servicesparcelle.dart';
import '../../services/gestion-culture/servicescampagne.dart';
import '../../models/gestion-culture/modelparcelle.dart';
import '../../models/gestion-culture/modelcampagne.dart';

class PlanificationPage extends StatefulWidget {
  final int code_expl;
  const PlanificationPage({super.key, required this.code_expl});

  @override
  State<PlanificationPage> createState() => _PlanificationPageState();
}

class _PlanificationPageState extends State<PlanificationPage> {
  final ParcelleService parcelleService = ParcelleService();
  final CampagneService campagneService = CampagneService();

  List<Parcelle> parcelles = [];
  List<Campagne> campagnes = [];
  int? selectedParcelle;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final nomController = TextEditingController();
  Map<DateTime, List<Campagne>> events = {};

  // Couleurs du thème
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFFC8E6C9);

  @override
  void initState() {
    super.initState();
    loadParcelles();
  }

  void loadParcelles() async {
    final data = await parcelleService.getByExploitation(widget.code_expl);
    setState(() => parcelles = data);
  }

  void loadCampagnes(int id_cham) async {
    final data = await campagneService.getByParcelle(id_cham);
    Map<DateTime, List<Campagne>> temp = {};
    for (var c in data) {
      DateTime date = DateTime.parse(c.date_debut);
      DateTime key = DateTime(date.year, date.month, date.day);
      temp.putIfAbsent(key, () => []).add(c);
    }
    setState(() {
      campagnes = data;
      events = temp;
    });
  }

  void saveCampagne() async {
    if (nomController.text.isEmpty) return;
    final camp = Campagne(
      id_camp: DateTime.now().millisecondsSinceEpoch,
      nom_camp: nomController.text,
      date_debut: selectedDay!.toIso8601String(),
      date_fin: selectedDay!.toIso8601String(),
      code_expl: widget.code_expl,
      id_cham: selectedParcelle!,
      statut: "planifiée",
    );
    await campagneService.create(camp);
    loadCampagnes(selectedParcelle!);
    nomController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Campagne planifiée avec succès !"), backgroundColor: Colors.green),
    );
  }

  List<Campagne> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Planification", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionTitle("Ma Parcelle"),
            _buildParcelleSelector(),

            const SizedBox(height: 20),
            _buildCalendarCard(),

            if (selectedDay != null && selectedParcelle != null) ...[
              const SizedBox(height: 20),
              _buildAddCampagneForm(),
            ],

            const SizedBox(height: 20),
            _buildSectionTitle("Campagnes du jour"),
            _buildDailyList(),

            const SizedBox(height: 20),
            _buildSectionTitle("Historique complet"),
            _buildFullList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS DESIGN ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildParcelleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedParcelle,
          hint: const Text("Sélectionner la terre à cultiver"),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) => setState(() { selectedDay = selected; focusedDay = focused; }),
        eventLoader: getEventsForDay,

        // Style du calendrier
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: accentGreen, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
    );
  }

  Widget _buildAddCampagneForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          TextField(
            controller: nomController,
            decoration: InputDecoration(
              hintText: "Nom de la nouvelle campagne...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.edit, color: primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: saveCampagne,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Planifier maintenant", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyList() {
    final daily = selectedDay != null ? getEventsForDay(selectedDay!) : [];
    if (daily.isEmpty) return const Text("Aucune activité ce jour.", style: TextStyle(color: Colors.grey));

    return Column(
      children: daily.map((c) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: accentGreen, child: Icon(Icons.eco, color: primaryGreen)),
          title: Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Début : ${c.date_debut.split('T')[0]}"),
        ),
      )).toList(),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: primaryGreen, width: 4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nom_camp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Statut: ${c.statut}", style: TextStyle(color: primaryGreen, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(c.date_debut.split('T')[0], style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}