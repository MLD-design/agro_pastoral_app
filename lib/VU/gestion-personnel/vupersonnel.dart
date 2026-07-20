import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../../models/gestion-compte/modeluser.dart';

class MyPersonnelPage extends StatefulWidget {
  final User user;
  const MyPersonnelPage({super.key, required this.user});

  @override
  _PersonnelPageState createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<MyPersonnelPage> {
  final service = PersonnelService();
  List<Personnel> list = [];
  bool loading = false;

  final nom = TextEditingController();
  final poste = TextEditingController();
  final salaire = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPersonnel();
  }

  void loadPersonnel() async {
    setState(() => loading = true);
    try {
      final data = await service.getByExploitation(widget.user.code_expl, widget.user.token);
      if (mounted) {
        setState(() {
          list = data;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de chargement: $e")));
    }
  }

  // --- STATISTIQUES DYNAMIQUES ---
  Widget _buildHeaderStats() {
    double totalSalaire = list.fold(0, (sum, item) => sum + item.salaire);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
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
          _statItem("Effectif", "${list.length}", Icons.people_outline),
          Container(height: 40, width: 1, color: Colors.white24),
          _statItem("Masse Salariale", "${totalSalaire.toInt()} FCFA", Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            // 🔴 ICI : L'icône du Header des statistiques est désormais en ROUGE VIF
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // --- LOGIQUE D'AJOUT ---
  void showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F4F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Nouvel Employé", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            const SizedBox(height: 25),
            _buildTextField(nom, "Nom & Prénom", Icons.person_rounded),
            const SizedBox(height: 15),
            _buildTextField(poste, "Poste (ex: technicien agricole, agronome)", Icons.work_rounded),
            const SizedBox(height: 15),
            _buildTextField(salaire, "Salaire (FCFA)", Icons.payments_rounded, isNumber: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (nom.text.isNotEmpty && salaire.text.isNotEmpty) {
                    await addPersonnel();
                    Navigator.pop(context);
                  }
                },
                child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
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
        prefixIcon: Icon(icon, color: const Color(0xFF1B4332)),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1B4332), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        floatingLabelStyle: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> addPersonnel() async {
    final newPerso = Personnel(
      code_per: 0,
      nom: nom.text,
      poste: poste.text,
      salaire: double.tryParse(salaire.text) ?? 0.0,
      code_expl: widget.user.code_expl,
    );

    await service.add(newPerso, widget.user.token);
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
      backgroundColor: const Color(0xFFF0F4F2),
      appBar: AppBar(
        title: const Text("EFFECTIFS DE LA FERME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B4332),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: loadPersonnel, icon: const Icon(Icons.sync_rounded, color: Colors.white))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        backgroundColor: const Color(0xFF1B4332),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("RECRUTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : RefreshIndicator(
        color: const Color(0xFF1B4332),
        onRefresh: () async => loadPersonnel(),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(20), child: _buildHeaderStats()),
            Expanded(
              child: list.isEmpty ? _buildEmptyState() : _buildAnimatedList(groupedByPoste),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedList(Map<String, List<Personnel>> groupedByPoste) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedByPoste.length,
      itemBuilder: (context, index) {
        String posteKey = groupedByPoste.keys.elementAt(index);
        List<Personnel> personnels = groupedByPoste[posteKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 12),
              child: Row(
                children: [
                  Text(posteKey.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 13, letterSpacing: 1)),
                  const SizedBox(width: 10),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
            ),
            ...personnels.map((p) => _buildEmployeeTile(p)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeTile(Personnel p) {
    return Dismissible(
      key: Key(p.code_per.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          leading: Container(
            width: 55, height: 55,
            decoration: BoxDecoration(color: const Color(0xFF1B4332).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(p.nom.isNotEmpty ? p.nom[0].toUpperCase() : "E", style: const TextStyle(color: Color(0xFF1B4332), fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          title: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF081C15))),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(FontAwesomeIcons.wallet, size: 12, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text("${p.salaire.toInt()} FCFA / mois", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network("https://cdn-icons-png.flaticon.com/512/6821/6821121.png", height: 150, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("L'équipe est vide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
          const Text("Commencez par recruter votre premier employé", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}