import 'package:agro_pastoral_app/models/gestion-culture/modelparcelle.dart';
import 'package:flutter/material.dart';
import '../models/gestion-exploitation/modelexploitation.dart';

class SelectedParcelleProvider with ChangeNotifier {
  Parcelle? _parcelle;

  Parcelle? get parcelle => _parcelle;

  void setExploitation(Exploitation exp) {
    _parcelle = exp as Parcelle?;
    notifyListeners(); // met à jour toutes les pages
  }
}