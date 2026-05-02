import 'package:flutter/material.dart';

import '../../models/gestion-culture/modelparcelle.dart';

import '../../models/gestion-culture/modelcampagne.dart';

import '../../services/gestion-culture/servicesrapport.dart';


class RapportculturePage extends StatefulWidget {

  final int code_expl;

  const RapportculturePage({super.key, required this.code_expl});

  @override

  State<RapportculturePage> createState() => _RapportPageState();

}

class _RapportPageState extends State<RapportculturePage> {

  final service = RapportService();

  List<Parcelle> parcelles = [];

  List<Campagne> campagnes = [];

  int? selectedParcelle;

  int? selectedCampagne;

  dynamic rapport;

  void loadRapport() async {

    final data = await service.getRapport(

      widget.code_expl,

      selectedParcelle!,

      selectedCampagne!,

    );

    setState(() => rapport = data);

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Rapport Culture"),

      ),

      body: Column(

        children: [

          // 🌱 PARCELLE

          DropdownButton<int>(

            value: selectedParcelle,

            hint: const Text("Parcelle"),

            items: parcelles.map((p) {

              return DropdownMenuItem(

                value: p.id_cham,

                child: Text(p.nom_cham),

              );

            }).toList(),

            onChanged: (v) {

              setState(() {

                selectedParcelle = v;

                selectedCampagne = null;

              });

              // load campagnes ici

            },

          ),

          // 🌾 CAMPAGNE

          DropdownButton<int>(

            value: selectedCampagne,

            hint: const Text("Campagne"),

            items: campagnes.map((c) {

              return DropdownMenuItem(

                value: c.id_camp,

                child: Text(c.nom_camp),

              );

            }).toList(),

            onChanged: (v) {

              setState(() => selectedCampagne = v);

            },

          ),

          ElevatedButton(

            onPressed: (selectedCampagne != null &&

                selectedParcelle != null)

                ? loadRapport

                : null,

            child: const Text("Générer rapport"),

          ),

          const SizedBox(height: 20),

          // 📊 AFFICHAGE

          if (rapport != null)

            Expanded(

              child: ListView(

                children: [

                  Text("Semence: ${rapport.quantiteSemence} kg"),

                  Text("Traitements: ${rapport.nombreTraitements}"),

                  Text("Récoltes: ${rapport.nombreRecoltes}"),

                  Text("Statut: ${rapport.statutRecolte}"),

                ],

              ),

            ),

        ],

      ),

    );

  }

}