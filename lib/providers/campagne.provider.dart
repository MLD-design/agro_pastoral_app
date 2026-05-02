import 'package:agro_pastoral_app/models/gestion-culture/modelcampagne.dart';
import 'package:flutter/material.dart';
import '../models/gestion-culture/modelcampagne.dart';

class SelectedCampagneProvider with ChangeNotifier {
  Campagne? _campagne;

  Campagne? get campagne => _campagne;

  void setExploitation(Campagne exp) {
    _campagne = exp;
    notifyListeners(); // met à jour toutes les pages
  }
}