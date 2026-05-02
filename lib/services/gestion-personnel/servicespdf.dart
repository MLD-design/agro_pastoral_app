import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<File> generateContratPdf(String nomEmploye, String typeContrat) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Container(
          padding: const pw.EdgeInsets.all(30),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- EN-TÊTE ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("EXPLOITATION AGRICOLE MODERNE",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text("Réf: CONTRAT-${DateTime.now().year}/${DateTime.now().millisecond}",
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 30),

              // --- TITRE DU DOCUMENT ---
              pw.Center(
                child: pw.Column(children: [
                  pw.Text("CONTRAT DE TRAVAIL",
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Type : $typeContrat",
                      style: pw.TextStyle(fontSize: 16, color: PdfColors.green900)),
                ]),
              ),
              pw.SizedBox(height: 40),

              // --- CORPS DU CONTRAT (ARTICLES) ---
              _buildArticle("ARTICLE 1 : LES PARTIES",
                  "Le présent contrat est conclu entre l'Exploitation Agricole, représentée par son gérant, et Monsieur/Madame $nomEmploye, désigné(e) comme l'Employé."),

              _buildArticle("ARTICLE 2 : FONCTIONS ET RÉMUNÉRATION",
                  "L'employé est recruté en tant que collaborateur sous le régime $typeContrat. Le salaire et les primes sont fixés selon les termes de la fiche de poste associée."),

              _buildArticle("ARTICLE 3 : OBLIGATIONS",
                  "L'employé s'engage à respecter le règlement intérieur de l'exploitation, les normes de sécurité et à assurer la maintenance du matériel confié."),

              pw.SizedBox(height: 20),
              pw.Bullet(text: "Lieu de travail : Siège de l'exploitation"),
              pw.Bullet(text: "Date d'effet : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),

              pw.Spacer(),

              // --- SIGNATURES ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignZone("L'EMPLOYEUR"),
                  _buildSignZone("L'EMPLOYÉ"),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text("Document généré numériquement - AgroPastoral App",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ),
            ],
          ),
        ),
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/contrat_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildArticle(String title, String content) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(content, textAlign: pw.TextAlign.justify, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildSignZone(String label) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(decoration: pw.TextDecoration.underline, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 50),
        pw.Text("Signature précédée de la mention\n'Lu et Approuvé'",
            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}