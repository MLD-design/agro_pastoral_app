import 'package:agro_pastoral_app/VU/gestion-compte/users_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-compte/servicesusers.dart';
import '../../services/gestion-personnel/servicespersonnel.dart';
import '../../models/gestion-personnel/modelpersonnel.dart';
import '../gestion-exploitation/gestionexploitation.dart';


class AdminScreen extends StatefulWidget {
  final User user;
  AdminScreen({required this.user});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<User> _users = [];
  List<Personnel> _personnelsSansCompte = [];
  bool _loading = true;

  final PersonnelService _personnelService = PersonnelService();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ✅ Chargement combiné des utilisateurs et du personnel en attente
  void _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final users = await UserService().listUsers(widget.user.token);
      final allPersonnel = await _personnelService.getAll();

      setState(() {
        _users = users.cast<User>();
        // On filtre : on garde uniquement le personnel qui n'a pas encore de compte (userId == null)
        _personnelsSansCompte = allPersonnel.where((p) => p.userId == null).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des données : $e");
      setState(() => _loading = false);
    }
  }

  void _deleteUser(int id) async {
    final ok = await UserService().deleteUser(widget.user.token, id);
    if (ok) _loadDashboardData();
  }

  // --- LOGIQUE DE DÉCONNEXION ---
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Déconnexion"),
          ],
        ),
        content: const Text("Voulez-vous vraiment quitter la session administrateur ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("QUITTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🔴 DIALOGUE DE CHOIX : COMPTE LIBRE OU LIÉ (Casse le blocage au démarrage)
  void _showAccountCreationChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B4332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF74C69D)),
            SizedBox(width: 10),
            Text("Nouveau compte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Choisissez l'option de création : \n\n• Compte libre : pour créer un gestionnaire ou admin directement.\n• Lier à un personnel : pour un employé déjà enregistré sur le terrain.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          // Option A : Compte Libre (Sans liaison de personnel obligatoire)
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // On génère une instance temporaire avec code_per à 0 pour indiquer au backend de ne pas faire de lien
              final personnelFictif = Personnel(
                  code_per: 0,
                  nom: "Compte Libre (Nouveau)",
                  poste: "gestionnaire",
                  salaire: 0,
                  code_expl: 0
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateUserScreen(admin: widget.user, personnelTarget: personnelFictif),
                ),
              ).then((_) => _loadDashboardData());
            },
            child: const Text("COMPTE LIBRE", style: TextStyle(color: Color(0xFF74C69D), fontWeight: FontWeight.bold)),
          ),

          // Option B : Associer à une fiche existante
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showPersonnelSelectionSheet();
            },
            child: const Text("LIER À UN PERSONNEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🔴 SÉLECTION DU PERSONNEL EN ATTENTE (BottomSheet)
  void _showPersonnelSelectionSheet() {
    if (_personnelsSansCompte.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun personnel en attente de compte actuellement.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B4332),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attribuer un compte à :",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _personnelsSansCompte.length,
                  itemBuilder: (context, index) {
                    final p = _personnelsSansCompte[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF74C69D),
                          child: Icon(Icons.person, color: Color(0xFF081C15)),
                        ),
                        title: Text(p.nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(p.poste.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateUserScreen(
                                admin: widget.user,
                                personnelTarget: p,
                              ),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildHeaderStats()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: _users.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildUserCard(_users[i]),
                childCount: _users.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExploitationPage()));
        },
        backgroundColor: const Color(0xFF2D6A4F),
        elevation: 10,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text("EXPLOITATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1B4332),
      leading: IconButton(
        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70),
        onPressed: _confirmLogout,
        tooltip: "Se déconnecter",
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "ADMINISTRATION",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF081C15), Color(0xFF1B4332)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
              onPressed: _showAccountCreationChoiceDialog, // 🔴 Redirection vers la nouvelle logique de choix
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF409167)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B4332).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(

            children: [
              Text("Communauté", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text("${_users.length} Utilisateurs", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.group_work_rounded, color: Colors.white, size: 30),
          )
        ],
      ),
    );
  }

  Widget _buildUserCard(User u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFD8F3DC),
              child: Text(u.username.isNotEmpty ? u.username[0].toUpperCase() : "?",
                  style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF081C15))),
            subtitle: _buildRoleBadge(u.role),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
              onPressed: () => _deleteUser(u.id),
            ),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    _buildInfoChip(Icons.numbers, "ID Expl: ${u.code_expl}"),
                    const SizedBox(width: 10),
                    _buildInfoChip(Icons.security, "Accès: OK"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(color: Color(0xFF1B4332), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text("Aucun utilisateur trouvé", style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}