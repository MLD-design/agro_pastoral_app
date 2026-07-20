import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/gestion-stock/servicesstock.dart';
import '../../models/gestion-compte/modeluser.dart';

class AddStockPage extends StatefulWidget {
  final User user;
  const AddStockPage({super.key, required this.user});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _uniteController = TextEditingController(text: "kg");
  final _seuilController = TextEditingController(text: "5");

  String selectedType = "intrant";
  File? _image;
  bool isLoading = false;

  // Couleurs harmonisées
  final Color primaryColor = const Color(0xFF1B4332);
  final Color backgroundColor = const Color(0xFFF8FAF9);

  final List<Map<String, dynamic>> categories = [
    {"id": "intrant", "label": "Intrant", "icon": Icons.science},
    {"id": "aliment", "label": "Aliment", "icon": Icons.set_meal},
    {"id": "medicament", "label": "Santé", "icon": Icons.medication},
    {"id": "equipement", "label": "Matériel", "icon": Icons.handyman},
  ];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final stockData = {
        "nom": _nomController.text,
        "type": selectedType,
        "quantite": int.parse(_quantiteController.text),
        "unite": _uniteController.text,
        "seuilAlerte": int.parse(_seuilController.text),
        "code_expl": widget.user.code_expl,
        "imagePath": _image?.path,
      };
      await StockService.addStock(stockData, widget.user.token);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // 🔴 Fond harmonisé
      appBar: AppBar(
        title: const Text("Nouveau Produit", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor, // 🔴 Vert profond
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 25),
              _sectionTitle("Catégorie"),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _sectionTitle("Détails du produit"),
              TextFormField(
                controller: _nomController,
                decoration: _inputStyle("Nom du produit", Icons.shopping_basket),
                validator: (v) => v!.isEmpty ? "Le nom est obligatoire" : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantiteController,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle("Quantité initiale", Icons.numbers),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _uniteController,
                      decoration: _inputStyle("Unité (kg, L, ...)", Icons.scale),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _seuilController,
                keyboardType: TextInputType.number,
                decoration: _inputStyle("Seuil d'alerte critique", Icons.warning_amber),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // 🔴 Vert profond
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ENREGISTRER LE PRODUIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          width: double.infinity, height: 180,
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
          ),
          child: _image == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 45, color: primaryColor.withOpacity(0.5)), const SizedBox(height: 10), const Text("Ajouter une photo")])
              : ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(_image!, fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        bool isSel = selectedType == cat['id'];
        return ChoiceChip(
          label: Text(cat['label']),
          selected: isSel,
          selectedColor: primaryColor, // 🔴 Vert profond
          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
          onSelected: (v) => setState(() => selectedType = cat['id']),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: primaryColor), // 🔴 Vert profond
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor.withOpacity(0.3))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor.withOpacity(0.3))),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 10),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)), // 🔴 Vert profond
  );
}