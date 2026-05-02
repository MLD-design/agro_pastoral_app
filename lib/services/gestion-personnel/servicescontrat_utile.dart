import '../../models/gestion-personnel/modelcontrat.dart';

Map<String, List<Contrat>> groupByType(List<Contrat> contrats) {
  final map = <String, List<Contrat>>{};

  for (var c in contrats) {
    map.putIfAbsent(c.type, () => []).add(c);
  }

  return map;
}