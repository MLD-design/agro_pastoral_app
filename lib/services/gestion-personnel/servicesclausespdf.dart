import 'package:pdf/widgets.dart' as pw;

import '../../models/gestion-personnel/modelcontrat.dart';

Future<List<int>> genererPdf(Contrat c) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Center(
            child: pw.Text("CONTRAT AGRICOLE",
                style: pw.TextStyle(fontSize: 20)),
          ),

          pw.SizedBox(height: 20),

          pw.Text("Employé ID : ${c.employeId}"),
          pw.Text("Exploitation : ${c.code_expl}"),
          pw.Text("Type : ${c.type}"),

          pw.SizedBox(height: 20),

          pw.Text("Clauses :"),
          pw.Text("• Respect des activités agricoles"),
          pw.Text("• Horaires liés aux saisons"),
          pw.Text("• Sécurité obligatoire"),
          pw.Text("• Utilisation correcte du matériel"),

          pw.SizedBox(height: 40),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Employeur"),
              pw.Text("Employé"),
            ],
          )
        ],
      ),
    ),
  );

  return pdf.save();
}