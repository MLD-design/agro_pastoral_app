import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/gestion-alerte/modelalerte.dart';
import '../../models/gestion-compte/modeluser.dart'; // Import du modèle User
import '../../services/gestion-alerte/servicesalerte.dart';

class AlertePage extends StatefulWidget {
  final User user; // On récupère l'utilisateur connecté
  const AlertePage({super.key, required this.user});

  @override
  State<AlertePage> createState() => _AlertePageState();
}

class _AlertePageState extends State<AlertePage> with SingleTickerProviderStateMixin {
  final service = AlerteService();
  List<Alerte> alertes = [];
  bool _isLoading = true;
  late TabController _tabController;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadAlertes();
    // Rafraîchissement automatique toutes le 10 secondes
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) => loadAlertes());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void loadAlertes() async {
    // On utilise directement le code_expl de l'utilisateur connecté
    final data = await service.getByExploitation(widget.user.code_expl);
    if (mounted) {
      setState(() {
        alertes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1B4332),
        title: Column(
          children: [
            const Text("MONITORING LIVE",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white70)),
            Text("Exploitation : ${widget.user.code_expl}",
                style: const TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF74C69D),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.notifications_active), text: "Alertes"),
            Tab(icon: Icon(Icons.insights), text: "Analyses"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAlerteTab(),
          _buildDashboardTab(),
        ],
      ),
    );
  }

  // --- ONGLET ALERTES (Design amélioré) ---
  Widget _buildAlerteTab() {
    if (alertes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text("Tout est sous contrôle", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertes.length,
      itemBuilder: (_, i) {
        final a = alertes[i];
        bool isActif = a.statut == "actif";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: isActif ? Colors.redAccent : Colors.greenAccent.shade700,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(a.message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${a.type.toUpperCase()}  •  Valeur: ${a.valeur} (Seuil: ${a.seuil})",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                    trailing: _buildActionIcon(a),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(Alerte a) {
    if (a.statut == "actif") {
      return Container(
        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
        child: IconButton(
            icon: const Icon(Icons.priority_high, color: Colors.redAccent),
            onPressed: () async {
              await service.traiter(a.idAlerte);
              loadAlertes();
            }
        ),
      );
    } else if (a.statut == "traité") {
      return Container(
        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
        child: IconButton(
            icon: const Icon(Icons.done_all, color: Colors.green),
            onPressed: () async {
              await service.archiver(a.idAlerte);
              loadAlertes();
            }
        ),
      );
    }
    return const Icon(Icons.archive_outlined, color: Colors.grey);
  }

  // --- ONGLET DASHBOARD ---
  Widget _buildDashboardTab() {
    final temps = alertes.where((a) => a.type == "temperature").map((a) => a.valeur).toList();
    final hums = alertes.where((a) => a.type == "humidite").map((a) => a.valeur).toList();
    final lastTemp = temps.isNotEmpty ? temps.last : 0.0;
    final lastHum = hums.isNotEmpty ? hums.last : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard("Température", "$lastTemp°C", Icons.thermostat, Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard("Humidité", "$lastHum%", Icons.water_drop, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 25),
          _buildChartCard("Historique Temps Réel", _buildLineChart(temps, hums)),
          const SizedBox(height: 25),
          _buildChartCard("Niveaux Actuels (%)", _buildBarChart(lastTemp, lastHum)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4332))),
          const SizedBox(height: 25),
          SizedBox(height: 220, child: chart),
        ],
      ),
    );
  }

  // --- LOGIQUE DES GRAPHIQUES (LineChart) ---
  Widget _buildLineChart(List<double> temps, List<double> hums) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _generateLineData(temps, Colors.orange),
          _generateLineData(hums, Colors.blueAccent),
        ],
      ),
    );
  }

  LineChartBarData _generateLineData(List<double> data, Color color) {
    return LineChartBarData(
      spots: data.isEmpty
          ? [const FlSpot(0, 0)]
          : List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  Widget _buildBarChart(double lastTemp, double lastHum) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: [
          _generateBarGroup(0, lastTemp, Colors.orange),
          _generateBarGroup(1, lastHum, Colors.blueAccent),
        ],
        titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(v == 0 ? "TEMP" : "HUM", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              );
            }))
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  BarChartGroupData _generateBarGroup(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 25,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Colors.grey.shade100),
      )
    ]);
  }
}