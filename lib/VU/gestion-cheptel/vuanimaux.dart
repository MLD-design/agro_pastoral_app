import 'package:flutter/material.dart';
import '../../services/gestion-cheptel/servicescheptel.dart';


class EnregistrerAnimalPage extends StatefulWidget {
  @override
  _EnregistrerAnimalPageState createState() => _EnregistrerAnimalPageState();
}

class _EnregistrerAnimalPageState extends State<EnregistrerAnimalPage> {
  final service = CheptelService();
  final identifiantController = TextEditingController();
  final raceController = TextEditingController();
  final ageController = TextEditingController();
  final sexeController = TextEditingController();

  final List<int> exploitations = [101, 102, 103]; // Exemple
  int? selectedExpl;

  void enregistrer() async {
    if (selectedExpl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Choisir exploitation")));
      return;
    }
    await service.enregistrerAnimal(selectedExpl!, {
      "identifiant": identifiantController.text,
      "race": raceController.text,
      "age": int.parse(ageController.text),
      "sexe": sexeController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Animal enregistré")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enregistrer animal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButton<int>(
            hint: Text("Sélectionner exploitation"),
            value: selectedExpl,
            items: exploitations.map((code) {
              return DropdownMenuItem<int>(
                value: code,
                child: Text("Exploitation $code"),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedExpl = value),
          ),
          TextField(controller: identifiantController, decoration: InputDecoration(labelText: "Identifiant")),
          TextField(controller: raceController, decoration: InputDecoration(labelText: "Race")),
          TextField(controller: ageController, decoration: InputDecoration(labelText: "Âge"), keyboardType: TextInputType.number),
          TextField(controller: sexeController, decoration: InputDecoration(labelText: "Sexe")),
          ElevatedButton(onPressed: enregistrer, child: Text("Enregistrer"))
        ]),
      ),
    );
  }
}
