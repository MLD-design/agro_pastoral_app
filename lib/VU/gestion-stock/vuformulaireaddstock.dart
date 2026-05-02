import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/gestion-exploitation/modelexploitation.dart';
import '../../services/gestion-exploitation/servicesexploitation.dart';
import '../../services/gestion-stock/servicesstock.dart';

class AddStockPage extends StatefulWidget {
  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  String nom = "";
  String type = "intrant";
  int quantite = 0;
  String unite = "kg";
  int seuil = 5;
  bool isLoading = false;
  File? image;
  final picker = ImagePicker();

  List<Exploitation> exploitations = [];
  int? selectedExpl;
  final exploitationService = ExploitationService();

  final List<Map<String, dynamic>> categories = [
    {"id": "intrant", "label": "Intrant", "icon": Icons.science},
    {"id": "aliment", "label": "Aliment", "icon": Icons.set_meal},
    {"id": "medicament", "label": "Médiament", "icon": Icons.medication},
    {"id": "equipement", "label": "Equipement", "icon": Icons.handyman},
  ];

  @override
  void initState() {
    super.initState();
    loadExploitations();
  }

  void loadExploitations() async {
    exploitations = await exploitationService.getAll();
    setState(() {});
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  void submit() async {
    if (!_formKey.currentState!.validate() || selectedExpl == null) return;
    _formKey.currentState!.save();
    setState(() => isLoading = true);
    await StockService.addStock({
      "nom": nom, "type": type, "quantite": quantite,
      "unite": unite, "seuilAlerte": seuil,
      "imagePath": image?.path, "code_expl": selectedExpl
    });
    setState(() => isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouveau Produit")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 25),
            _buildLabel("Exploitation"),
            DropdownButtonFormField<int>(
              value: selectedExpl,
              decoration: _inputDeco(Icons.location_on),
              items: exploitations.map((e) => DropdownMenuItem(value: e.code_expl, child: Text(e.nom_expl))).toList(),
              onChanged: (v) => setState(() => selectedExpl = v),
            ),
            const SizedBox(height: 20),
            _buildLabel("Catégorie"),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            TextFormField(
              decoration: _inputDeco(Icons.shopping_basket).copyWith(labelText: "Nom du produit"),
              validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
              onSaved: (v) => nom = v!,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco(Icons.numbers).copyWith(labelText: "Qté initiale"),
                    onSaved: (v) => quantite = int.parse(v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: _inputDeco(Icons.scale).copyWith(labelText: "Unité (kg, L...)"),
                    initialValue: "kg",
                    onSaved: (v) => unite = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: _inputDeco(Icons.warning).copyWith(labelText: "Seuil d'alerte"),
              initialValue: "5",
              onSaved: (v) => seuil = int.parse(v!),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isLoading ? null : submit,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ENREGISTRER LE STOCK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Center(
        child: Container(
          width: double.infinity, height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: image == null
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40, color: Colors.grey), Text("Ajouter une photo")])
              : ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(image!, fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        bool isSelected = type == cat['id'];
        return ChoiceChip(
          label: Text(cat['label']),
          avatar: Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : Colors.black),
          selected: isSelected,
          selectedColor: const Color(0xFF1B5E20),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          onSelected: (v) => setState(() => type = cat['id']),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDeco(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
  );
}