// lib/models/gestion-culture/modelsuivisemi.dart
class StepModel {
  final bool completed;
  final String? date;
  final Map<String, dynamic>? data;

  StepModel({required this.completed, this.date, this.data});

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      completed: json['completed'] == true,
      date: json['date']?.toString(),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

class ObservationModel {
  final int id;
  final String date;
  final String note;
  final Map<String, dynamic>? data;

  ObservationModel({required this.id, required this.date, required this.note, this.data});

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    return ObservationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

class PassageRecolteModel {
  final int id;
  final String date;
  final double quantite;
  final String unite;
  final String? qualite;
  final String? note;

  PassageRecolteModel({
    required this.id, required this.date, required this.quantite,
    required this.unite, this.qualite, this.note,
  });

  factory PassageRecolteModel.fromJson(Map<String, dynamic> json) {
    return PassageRecolteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date']?.toString() ?? '',
      quantite: (json['quantite'] as num? ?? 0).toDouble(),
      unite: json['unite']?.toString() ?? 'kg',
      qualite: json['qualite']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class SemisPhaseModel {
  final StepModel semis;
  final StepModel levee;
  final List<ObservationModel> observations;

  SemisPhaseModel({required this.semis, required this.levee, required this.observations});

  factory SemisPhaseModel.fromJson(Map<String, dynamic> json) {
    return SemisPhaseModel(
      semis: StepModel.fromJson(json['semis'] ?? {}),
      levee: StepModel.fromJson(json['levee'] ?? {}),
      observations: (json['observations'] as List? ?? [])
          .map((e) => ObservationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class RecoltePhaseModel {
  final List<PassageRecolteModel> passages;
  final bool cloturee;
  final String? dateCloture;

  RecoltePhaseModel({required this.passages, required this.cloturee, this.dateCloture});

  factory RecoltePhaseModel.fromJson(Map<String, dynamic> json) {
    return RecoltePhaseModel(
      passages: (json['passages'] as List? ?? [])
          .map((e) => PassageRecolteModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      cloturee: json['cloturee'] == true,
      dateCloture: json['date_cloture']?.toString(),
    );
  }

  double get totalRecolte => passages.fold(0.0, (sum, p) => sum + p.quantite);
}

class TraitementModel {
  final int id;
  final String description;
  final String phase; // 'Semis' ou 'Recolte'
  final String date;
  final Map<String, dynamic>? data;

  TraitementModel({required this.id, required this.description, required this.phase, required this.date, this.data});

  factory TraitementModel.fromJson(Map<String, dynamic> json) {
    return TraitementModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      phase: json['phase']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

class PhaseSuiviModel {
  final int idCamp;
  final String statusCouleur;
  final SemisPhaseModel semis;
  final RecoltePhaseModel recolte;
  final List<TraitementModel> traitements;

  PhaseSuiviModel({
    required this.idCamp,
    required this.statusCouleur,
    required this.semis,
    required this.recolte,
    required this.traitements,
  });

  factory PhaseSuiviModel.fromJson(Map<String, dynamic> json) {
    return PhaseSuiviModel(
      idCamp: json['id_camp'] is int ? json['id_camp'] : int.tryParse(json['id_camp'].toString()) ?? 0,
      statusCouleur: json['status_couleur']?.toString() ?? 'VERT',
      semis: SemisPhaseModel.fromJson(json['semis'] ?? {}),
      recolte: RecoltePhaseModel.fromJson(json['recolte'] ?? {}),
      traitements: (json['traitements'] as List? ?? [])
          .map((e) => TraitementModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
