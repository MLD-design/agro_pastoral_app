import 'package:flutter/material.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-personnel/servicespersonnel.dart'; // Service nécessaire
import 'vuconge.dart';
import 'vucontrat.dart';
import 'vupaie.dart';
import 'vupersonnel.dart';

class PersonnelPage extends StatefulWidget {
  final User user;
  const PersonnelPage({super.key, required this.user});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  final PersonnelService _personnelService = PersonnelService();
  int _totalPersonnel = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEffectif();
  }

  // 🔴 Chargement de l'effectif total
  Future<void> _loadEffectif() async {
    try {
      final list = await _personnelService.getAll();
      if (mounted) {
        setState(() {
          _totalPersonnel = list.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B4332),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              centerTitle: true,
              title: const Text("RESSOURCES HUMAINES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5)),
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)])),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diversity_3, size: 60, color: Colors.white24),
                      Text("Exploitation: ${widget.user.code_expl}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // 🔴 Affichage dynamique de l'effectif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF1B4332).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.group, color: Color(0xFF1B4332)),
                        const SizedBox(width: 10),
                        Text(
                          _isLoading ? "Chargement effectif..." : "Effectif total : $_totalPersonnel collaborateurs",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildEnhancedMenuCard(context, "Membres", "Inscrire & Gérer", Icons.badge_outlined, const Color(0xFF4361EE), () async {
                        // 🔴 .then permet de recharger le total en revenant de la page
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => MyPersonnelPage(user: widget.user)));
                        _loadEffectif();
                      }),
                      _buildEnhancedMenuCard(context, "Contrats", "Documents RH", Icons.history_edu_rounded, const Color(0xFFF72585), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContratPage(user: widget.user)))),
                      _buildEnhancedMenuCard(context, "Absences", "Suivi Congés", Icons.calendar_month_rounded, const Color(0xFFFB8500), () => Navigator.push(context, MaterialPageRoute(builder: (_) => CongePage(user: widget.user)))),
                      _buildEnhancedMenuCard(context, "Salaires", "Paies & Primes", Icons.account_balance_wallet_rounded, const Color(0xFF2D6A4F), () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaiementPage(user: widget.user)))),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.withOpacity(0.05)), boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2B2D42))),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}