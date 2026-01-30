// ignore_for_file: avoid_print

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfService {
  // Méthode pour générer un PDF avec les résultats OCR
  Future<File> generateOcrPdf({
    required String title,
    required Map<String, dynamic> ocrData,
    required String extractedText,
    required String intent,
    required double confidence,
    required int extractedCount,
  }) async {
    final pdf = pw.Document();

    // Ajouter une page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            _buildHeader(title),
            pw.SizedBox(height: 20),

            // Informations extraites
            _buildExtractedInfo(ocrData),
            pw.SizedBox(height: 20),

            // Statistiques
            _buildStatistics(intent, confidence, extractedCount),
            pw.SizedBox(height: 20),

            // Texte original
            _buildOriginalText(extractedText),

            // Pied de page
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    // Sauvegarder le PDF
    return await _savePdf(pdf, title);
  }

  // Méthode pour générer un PDF de l'historique
  Future<File> generateHistoryPdf({
    required String title,
    required List<Map<String, dynamic>> history,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            _buildHeader(title),
            pw.SizedBox(height: 20),

            // Statistiques
            _buildHistoryStats(history),
            pw.SizedBox(height: 20),

            // Tableau de l'historique
            _buildHistoryTable(history),

            // Pied de page
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return await _savePdf(pdf, title);
  }

  // En-tête du PDF
  pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Service OCR',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'PDF',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.blue,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue),
      ],
    );
  }

  // Informations extraites
  pw.Widget _buildExtractedInfo(Map<String, dynamic> ocrData) {
    final items = <pw.Widget>[];

    if (ocrData['phone'] != null && ocrData['phone'].toString().isNotEmpty) {
      items.add(_buildInfoItem('Téléphone', ocrData['phone']));
    }

    if (ocrData['address'] != null &&
        ocrData['address'].toString().isNotEmpty) {
      items.add(_buildInfoItem('Adresse', ocrData['address']));
    }

    if (ocrData['name'] != null && ocrData['name'].toString().isNotEmpty) {
      items.add(_buildInfoItem('Nom', ocrData['name']));
    }

    if (ocrData['email'] != null && ocrData['email'].toString().isNotEmpty) {
      items.add(_buildInfoItem('Email', ocrData['email']));
    }

    if (ocrData['amount'] != null) {
      items.add(_buildInfoItem('Montant', '${ocrData['amount']} Ar'));
    }

    if (ocrData['title'] != null && ocrData['title'].toString().isNotEmpty) {
      items.add(_buildInfoItem('Titre/Objet', ocrData['title']));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Informations extraites',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(children: items),
        ),
      ],
    );
  }

  pw.Widget _buildInfoItem(String label, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              value.toString(),
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Statistiques OCR
  pw.Widget _buildStatistics(
    String intent,
    double confidence,
    int extractedCount,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Statistiques de l\'extraction',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildStatCard(
                'Intention détectée',
                intent,
                PdfColors.blue,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _buildStatCard(
                'Confiance',
                '${(confidence * 100).toStringAsFixed(1)}%',
                PdfColors.green,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _buildStatCard(
                'Informations',
                '$extractedCount/6',
                PdfColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    // Fonction pour créer une couleur avec opacité
    PdfColor createColorWithOpacity(PdfColor baseColor, double opacity) {
      final int alpha = (opacity * 255).round();
      final int red = baseColor.red as int;
      final int green = baseColor.green as int;
      final int blue = baseColor.blue as int;

      // Format ARGB: 0xAARRGGBB
      final int colorValue = (alpha << 24) | (red << 16) | (green << 8) | blue;
      return PdfColor.fromInt(colorValue);
    }

    final PdfColor lightColor = createColorWithOpacity(color, 0.1);
    final PdfColor borderColor = createColorWithOpacity(color, 0.3);

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Texte original
  pw.Widget _buildOriginalText(String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Texte original',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ),
      ],
    );
  }

  // Statistiques historiques
  pw.Widget _buildHistoryStats(List<Map<String, dynamic>> history) {
    final total = history.length;
    final successful = history.where((item) => item['success'] == true).length;
    final successRate = total > 0 ? (successful / total * 100) : 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Statistiques de l\'historique',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildStatCard(
                'Total extractions',
                '$total',
                PdfColors.blue,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _buildStatCard(
                'Extractions réussies',
                '$successful',
                PdfColors.green,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _buildStatCard(
                'Taux de réussite',
                '${successRate.toStringAsFixed(1)}%',
                PdfColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tableau de l'historique
  pw.Widget _buildHistoryTable(List<Map<String, dynamic>> history) {
    final List<List<String>> data = history.map((item) {
      final dateTime = item['datetime'] as DateTime;
      final content = item['content'].toString();
      final truncatedContent = content.length > 50
          ? '${content.substring(0, 50)}...'
          : content;

      return [
        '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        item['type'].toString(),
        truncatedContent,
        item['success'] ? 'Succès' : 'Échec',
      ];
    }).toList();

    // Fonction pour créer une couleur avec opacité
    PdfColor createColorWithOpacity(PdfColor baseColor, double opacity) {
      final int alpha = (opacity * 255).round();
      final int red = baseColor.red as int;
      final int green = baseColor.green as int;
      final int blue = baseColor.blue as int;

      // Format ARGB: 0xAARRGGBB
      final int colorValue = (alpha << 24) | (red << 16) | (green << 8) | blue;
      return PdfColor.fromInt(colorValue);
    }

    final PdfColor headerBgColor = createColorWithOpacity(PdfColors.blue, 0.1);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails des extractions',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          context: null,
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headers: ['Date', 'Type', 'Contenu', 'Statut'],
          data: data,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration: pw.BoxDecoration(color: headerBgColor),
          rowDecoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
          ),
        ),
      ],
    );
  }

  // Pied de page
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
            pw.Text(
              'Service OCR - Extrait de données',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  // Sauvegarder le PDF
  Future<File> _savePdf(pw.Document pdf, String title) async {
    String path;

    if (Platform.isWindows) {
      // Pour Windows : sauvegarder dans le dossier Téléchargements
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null) {
        throw Exception('Impossible de trouver le dossier utilisateur');
      }

      final downloadsPath = '$userProfile\\Downloads';
      final downloadsDir = Directory(downloadsPath);

      // Créer le dossier s'il n'existe pas
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final fileName =
          'OCR_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      path = '${downloadsDir.path}\\$fileName';

      print('PDF genere pour Windows : $path');
    } else {
      // Pour Android/iOS : utiliser le dossier de l'application
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'OCR_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      path = '${directory.path}/$fileName';

      print('PDF genere pour mobile : $path');
    }

    final file = File(path);
    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);

    print('PDF cree avec succes : ${pdfBytes.length} bytes');

    // Vérifier que le fichier a bien été créé
    if (await file.exists()) {
      final fileSize = await file.length();
      print('Fichier verifie : $fileSize bytes');

      // Ouvrir automatiquement avec Edge sur Windows
      if (Platform.isWindows) {
        // Attendre un peu pour que le fichier soit complètement écrit
        await Future.delayed(Duration(milliseconds: 300));
        await _openPdfWithEdge(path);
      }
    } else {
      print('ERREUR : Le fichier n\'a pas ete cree');
    }

    return file;
  }

  // Ouvrir le PDF avec Microsoft Edge (Windows uniquement)
  Future<void> _openPdfWithEdge(String filePath) async {
    try {
      print('Tentative d\'ouverture du PDF...');
      print('Chemin du fichier : $filePath');

      // Vérifier que le fichier existe
      final file = File(filePath);
      if (!await file.exists()) {
        print('ERREUR : Le fichier n\'existe pas');
        return;
      }

      // Méthode 1 : Utiliser "start" avec le chemin entre guillemets
      print('Methode 1 : Utilisation de start...');
      final result1 = await Process.run('cmd', [
        '/c',
        'start',
        '',
        '"$filePath"',
      ], runInShell: true);

      if (result1.exitCode == 0) {
        print('Succes avec start');
        return;
      }
      print('Start a echoue avec code : ${result1.exitCode}');

      // Attendre un peu avant d'essayer une autre méthode
      await Future.delayed(Duration(seconds: 1));

      // Méthode 2 : Utiliser msedge directement
      print('Methode 2 : Utilisation de msedge...');
      try {
        final result2 = await Process.run('msedge', [
          filePath,
        ], runInShell: true);
        print('msedge resultat : exitCode=${result2.exitCode}');
      } catch (e) {
        print('Erreur avec msedge : $e');
      }

      // Attendre encore un peu
      await Future.delayed(Duration(seconds: 2));

      // Méthode 3 : Ouvrir le dossier contenant le fichier
      print('Methode 3 : Ouverture du dossier...');
      final directory = File(filePath).parent.path;
      await Process.run('explorer', [directory], runInShell: true);
      print('Dossier ouvert : $directory');
    } catch (e) {
      print('Erreur lors de l\'ouverture du PDF : $e');
      print('Type d\'erreur : ${e.runtimeType}');

      // Dernière tentative : ouvrir juste le dossier
      try {
        final dir = File(filePath).parent.path;
        await Process.run('explorer', [dir], runInShell: true);
        print('Dossier ouvert en secours');
      } catch (e2) {
        print('Impossible d\'ouvrir le dossier : $e2');
      }
    }
  }

  // Prévisualiser le PDF
  Future<void> previewPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdfFile.readAsBytes(),
    );
  }
}
