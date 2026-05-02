import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/gestion-alerte/modelalerte.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../services/gestion-alerte/servicesalerte.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';

class AlertePage extends StatefulWidget {
  @override
  State<AlertePage> createState() => _AlertePageState();
}

class _AlertePageState extends State<AlertePage> with SingleTickerProviderStateMixin {
  final service = AlerteService();
  final exploitationService = ExploitationService();

  List<Alerte> alertes = [];
  List<Exploitation> exploitations = [];
  Exploitation? selected;
  late TabController _tabController;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadExploitations();
    refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) => loadAlertes());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void loadExploitations() async {
    final data = await exploitationService.getAll();
    setState(() => exploitations = data);
  }

  void loadAlertes() async {
    if (selected == null) return;
    final data = await service.getByExploitation(selected!.code_expl);
    setState(() => alertes = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Monitoring & Alertes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green.shade700,
          tabs: [
            Tab(icon: Icon(Icons.notifications_active_outlined), text: "Alertes"),
            Tab(icon: Icon(Icons.analytics_outlined), text: "Dashboard"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildExploitationSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlerteTab(),
                _buildDashboardTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploitationSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: DropdownButtonFormField<Exploitation>(
        value: selected,
        decoration: InputDecoration(
          labelText: "Exploitation active",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        items: exploitations.map((e) => DropdownMenuItem(value: e, child: Text(e.nom_expl))).toList(),
        onChanged: (v) {
          setState(() => selected = v);
          loadAlertes();
        },
      ),
    );
  }

  // --- ONGLET ALERTES ---
  Widget _buildAlerteTab() {
    if (alertes.isEmpty) return Center(child: Text("Aucune alerte pour le moment"));
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: alertes.length,
      itemBuilder: (_, i) {
        final a = alertes[i];
        bool isCritical = a.statut == "actif";
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 6, color: isCritical ? Colors.red : Colors.green),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(a.message, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${a.type.toUpperCase()} • Valeur: ${a.valeur} (Seuil: ${a.seuil})"),
                      trailing: _buildActionIcon(a),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(Alerte a) {
    if (a.statut == "actif") {
      return CircleAvatar(
        backgroundColor: Colors.red.shade50,
        child: IconButton(icon: Icon(Icons.check, color: Colors.red), onPressed: () async {
          await service.traiter(a.idAlerte);
          loadAlertes();
        }),
      );
    } else if (a.statut == "traité") {
      return CircleAvatar(
        backgroundColor: Colors.green.shade50,
        child: IconButton(icon: Icon(Icons.archive_outlined, color: Colors.green), onPressed: () async {
          await service.archiver(a.idAlerte);
          loadAlertes();
        }),
      );
    }
    return Icon(Icons.inventory_2_outlined, color: Colors.grey);
  }

  // --- ONGLET DASHBOARD ---
  Widget _buildDashboardTab() {
    final temps = alertes.where((a) => a.type == "temperature").map((a) => a.valeur).toList();
    final hums = alertes.where((a) => a.type == "humidite").map((a) => a.valeur).toList();
    final lastTemp = temps.isNotEmpty ? temps.last : 0.0;
    final lastHum = hums.isNotEmpty ? hums.last : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard("Température", "$lastTemp°C", Icons.thermostat, Colors.red),
              SizedBox(width: 12),
              _buildStatCard("Humidité", "$lastHum%", Icons.water_drop, Colors.blue),
            ],
          ),
          SizedBox(height: 24),
          _buildChartCard("Historique des relevés", _buildLineChart(temps, hums)),
          SizedBox(height: 24),
          _buildChartCard("Comparaison instantanée", _buildBarChart(lastTemp, lastHum)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 20),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> temps, List<double> hums) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _generateLineData(temps, Colors.red),
          _generateLineData(hums, Colors.blue),
        ],
      ),
    );
  }

  LineChartBarData _generateLineData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  Widget _buildBarChart(double lastTemp, double lastHum) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: [
          _generateBarGroup(0, lastTemp, Colors.red),
          _generateBarGroup(1, lastHum, Colors.blue),
        ],
        titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
              return Text(v == 0 ? "Temp" : "Hum", style: TextStyle(fontSize: 10));
            }))
        ),
      ),
    );
  }

  BarChartGroupData _generateBarGroup(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 18, borderRadius: BorderRadius.circular(4))
    ]);
  }
}