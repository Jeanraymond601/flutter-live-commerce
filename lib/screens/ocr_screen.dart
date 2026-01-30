import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/ocr_model.dart';
import '../services/ocr_service.dart';
import '../services/pdf_service.dart';
import '../widgets/ocr_widget.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen>
    with SingleTickerProviderStateMixin {
  final OcrService _ocrService = OcrService();
  final PdfService _pdfService = PdfService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  OcrModel? _textResult;
  OcrModel? _imageResult;
  bool _isTextAnalyzing = false;
  bool _isImageAnalyzing = false;
  bool _isFileUploading = false;
  bool _isPdfGenerating = false;
  String _extractedImageText = '';
  File? _selectedImageFile;
  String? _selectedFileName;
  Uint8List? _webImageBytes;

  // Variables pour le compteur
  int _countdownValue = 5;
  Timer? _countdownTimer;
  bool _isCountingDown = false;

  // Animation pour le scan
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  // Historique des extractions
  List<Map<String, dynamic>> _extractionHistory = [];

  // Thème - Utilisation exclusive du bleu
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _primaryLightColor = const Color(0xFFE3F2FD);
  final Color _primaryDarkColor = const Color(0xFF0D47A1);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _errorColor = const Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _loadInitialHistory();

    // Initialiser l'animation de scan
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _countdownTimer?.cancel();
    _scanController.dispose();
    super.dispose();
  }

  void _loadInitialHistory() {
    _extractionHistory = [
      {
        'id': '1',
        'type': 'Texte',
        'datetime': DateTime.now().subtract(const Duration(minutes: 10)),
        'content': 'Commande #12345 - 034 12 34 56',
        'success': true,
      },
      {
        'id': '2',
        'type': 'Image',
        'datetime': DateTime.now().subtract(const Duration(hours: 1)),
        'content': 'Facture restaurant - 032 11 22 33',
        'success': true,
      },
      {
        'id': '3',
        'type': 'Texte',
        'datetime': DateTime.now().subtract(const Duration(hours: 2)),
        'content': 'Livraison urgente - 033 99 88 77',
        'success': true,
      },
    ];
  }

  Future<void> _pickAndUploadFile() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image != null) {
      setState(() => _isFileUploading = true);

      try {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedFileName = image.name;
            _isFileUploading = false;
          });
        } else {
          final file = File(image.path);
          await Future.delayed(const Duration(milliseconds: 500));

          setState(() {
            _selectedImageFile = file;
            _selectedFileName = path.basename(image.path);
            _isFileUploading = false;
          });
        }
      } catch (e) {
        setState(() => _isFileUploading = false);
        _showErrorAlert('Erreur lors du chargement: $e');
      }
    }
  }

  Widget _buildImagePreview() {
    if (_isFileUploading) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScanAnimation(),
            const SizedBox(height: 16),
            Text(
              'Traitement en cours...',
              style: TextStyle(
                color: _primaryDarkColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chargement de l\'image',
              style: TextStyle(color: _primaryColor, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if ((kIsWeb && _webImageBytes != null) ||
        (!kIsWeb && _selectedImageFile != null)) {
      return ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            kIsWeb
                ? Image.memory(
                    _webImageBytes!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  )
                : Image.file(
                    _selectedImageFile!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedFileName ?? 'Image',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            size: 56,
            color: _primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Document à analyser',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryDarkColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Formats supportés: JPG, PNG',
            textAlign: TextAlign.center,
            style: TextStyle(color: _primaryColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _clearTextResults() {
    setState(() {
      _textController.clear();
      _textResult = null;
    });
  }

  void _clearImageResults() {
    setState(() {
      _selectedImageFile = null;
      _selectedFileName = null;
      _webImageBytes = null;
      _imageResult = null;
      _extractedImageText = '';
    });
  }

  void _startTextExtraction() {
    if (_textController.text.trim().isEmpty) {
      _showErrorAlert(
        'Veuillez saisir du texte avant de démarrer l\'extraction',
      );
      return;
    }

    setState(() {
      _isCountingDown = true;
      _countdownValue = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownValue--;
      });

      if (_countdownValue == 0) {
        timer.cancel();
        _performTextExtraction();
      }
    });
  }

  Future<void> _performTextExtraction() async {
    setState(() {
      _isCountingDown = false;
      _isTextAnalyzing = true;
    });

    final result = await _ocrService.analyzeText(_textController.text, 'TEXT');

    _addToHistory(
      type: 'Texte',
      content: _textController.text.length > 30
          ? '${_textController.text.substring(0, 30)}...'
          : _textController.text,
      success: true,
    );

    setState(() {
      _textResult = result;
      _isTextAnalyzing = false;
    });

    if (mounted) {
      _showExtractionResult(result);
    }
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _errorColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Compris',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessAlert(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _successColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showExtractionResult(OcrModel result) {
    showDialog(
      context: context,
      builder: (context) => _buildResultDialog(result),
    );
  }

  Widget _buildResultDialog(OcrModel result) {
    final extractedCount = result.extractedFieldsCount;
    final hasGoodExtraction = extractedCount >= 3;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: hasGoodExtraction ? _successColor : _warningColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasGoodExtraction
                          ? Icons.check_circle
                          : Icons.warning_amber,
                      color: hasGoodExtraction ? _successColor : _warningColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résultats d\'extraction',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$extractedCount informations extraites',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.list_alt, color: _primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Informations extraites',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryDarkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (result.phone != null && result.phone!.isNotEmpty)
                        _buildResultItem(
                          Icons.phone,
                          'Numéro de téléphone',
                          result.phone!,
                        ),

                      if (result.address != null && result.address!.isNotEmpty)
                        _buildResultItem(
                          Icons.location_on,
                          'Adresse',
                          result.address!,
                        ),

                      if (result.name != null && result.name!.isNotEmpty)
                        _buildResultItem(Icons.person, 'Nom', result.name!),

                      if (result.extractedEmail != null &&
                          result.extractedEmail!.isNotEmpty)
                        _buildResultItem(
                          Icons.email,
                          'Email',
                          result.extractedEmail!,
                        ),

                      if (result.extractedAmount != null)
                        _buildResultItem(
                          Icons.attach_money,
                          'Montant',
                          '${result.extractedAmount} Ar',
                        ),

                      if (result.title != null && result.title!.isNotEmpty)
                        _buildResultItem(
                          Icons.title,
                          'Titre/Objet',
                          result.title!,
                        ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.summarize, color: _primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Résumé de l\'extraction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryDarkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryLightColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Score de confiance',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _primaryDarkColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(result.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryDarkColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: result.confidence,
                              backgroundColor: Colors.grey[200],
                              color: result.confidence > 0.7
                                  ? _successColor
                                  : result.confidence > 0.4
                                  ? Colors.orange
                                  : Colors.red,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Informations extraites',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _primaryDarkColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$extractedCount/6',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryDarkColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.flag, color: _primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Intention détectée',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryDarkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryLightColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment,
                              color: _primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.intent,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryDarkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Basé sur l\'analyse du texte',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Fermer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isPdfGenerating
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _generatePdf(result);
                                    },
                              icon: _isPdfGenerating
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(
                                _isPdfGenerating
                                    ? 'Génération...'
                                    : 'Exporter PDF',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(OcrModel result) async {
    setState(() => _isPdfGenerating = true);

    try {
      final pdfFile = await _pdfService.generateOcrPdf(
        title: 'Résultats d\'extraction OCR',
        ocrData: {
          'phone': result.phone,
          'address': result.address,
          'name': result.name,
          'email': result.extractedEmail,
          'amount': result.extractedAmount,
          'title': result.title,
        },
        extractedText: _extractedImageText.isNotEmpty
            ? _extractedImageText
            : _textController.text,
        intent: result.intent,
        confidence: result.confidence,
        extractedCount: result.extractedFieldsCount,
      );

      await _pdfService.previewPdf(pdfFile);

      _showSuccessAlert(
        'PDF généré',
        'Le fichier PDF a été généré avec succès',
      );
    } catch (e) {
      _showErrorAlert('Erreur lors de la génération du PDF: $e');
    } finally {
      setState(() => _isPdfGenerating = false);
    }
  }

  Future<void> _analyzeImage() async {
    if ((kIsWeb && _webImageBytes == null) ||
        (!kIsWeb && _selectedImageFile == null)) {
      _showErrorAlert('Veuillez d\'abord sélectionner une image');
      return;
    }

    setState(() => _isImageAnalyzing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      final extractedText = await _ocrService.extractTextFromImage();
      final result = await _ocrService.analyzeText(extractedText, 'IMAGE');

      _addToHistory(
        type: 'Image',
        content: extractedText.length > 30
            ? '${extractedText.substring(0, 30)}...'
            : extractedText,
        success: true,
      );

      setState(() {
        _imageResult = result;
        _extractedImageText = extractedText;
        _isImageAnalyzing = false;
      });

      if (mounted) {
        _showExtractionResult(result);
      }
    } catch (e) {
      setState(() => _isImageAnalyzing = false);
      _showErrorAlert('Erreur lors de l\'analyse de l\'image: $e');
    }
  }

  void _addToHistory({
    required String type,
    required String content,
    required bool success,
  }) {
    setState(() {
      _extractionHistory.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'datetime': DateTime.now(),
        'content': content,
        'success': success,
      });

      if (_extractionHistory.length > 20) {
        _extractionHistory = _extractionHistory.sublist(0, 20);
      }
    });
  }

  Widget _buildScanAnimation() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3), width: 2),
      ),
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(150, 150),
            painter: _ScanPainter(_scanAnimation.value, _primaryColor),
          );
        },
      ),
    );
  }

  Future<void> _exportHistoryPdf() async {
    setState(() => _isPdfGenerating = true);

    try {
      final pdfFile = await _pdfService.generateHistoryPdf(
        title: 'Historique des extractions OCR',
        history: _extractionHistory,
      );

      await _pdfService.previewPdf(pdfFile);

      _showSuccessAlert(
        'Historique exporté',
        'L\'historique a été exporté en PDF avec succès',
      );
    } catch (e) {
      _showErrorAlert('Erreur lors de l\'export de l\'historique: $e');
    } finally {
      setState(() => _isPdfGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service OCR'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: _primaryDarkColor,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: _primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.text_fields), text: 'Saisie Texte'),
                  Tab(icon: Icon(Icons.image), text: 'Image'),
                  Tab(icon: Icon(Icons.history), text: 'Historique'),
                ],
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
        body: Container(
          color: _backgroundColor,
          child: TabBarView(
            children: [
              _buildTextInputTab(),
              _buildImageTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, _primaryLightColor],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.text_fields,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Analyse de texte',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    focusNode: _textFocusNode,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Collez ou tapez votre texte ici...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(18),
                      prefixIcon: Icon(Icons.paste, color: _primaryColor),
                      suffixIcon: IconButton(
                        onPressed: _clearTextResults,
                        icon: const Icon(Icons.clear, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Exemple: "Je souhaite commander pour 034 12 34 56, adresse: Analakely, Antananarivo, email: jean@example.com"',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),

                  if (_isCountingDown)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Démarrage dans:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _primaryDarkColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [_primaryColor, _primaryDarkColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: CircularProgressIndicator(
                                    value: (5 - _countdownValue) / 5,
                                    strokeWidth: 6,
                                    color: Colors.white,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    '$_countdownValue',
                                    key: ValueKey(_countdownValue),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Préparation de l\'analyse...',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isCountingDown || _isTextAnalyzing)
                          ? null
                          : _startTextExtraction,
                      icon: _isTextAnalyzing
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow, size: 24),
                      label: Text(
                        _isCountingDown
                            ? 'Compte à rebours...'
                            : _isTextAnalyzing
                            ? 'Analyse en cours...'
                            : 'Démarrer l\'analyse',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_textResult != null) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: OcrResultWidget(
                  result: _textResult!,
                  sourceType: 'TEXT',
                  primaryColor: _primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, _primaryLightColor.withOpacity(0.3)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Analyse d\'image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _selectedImageFile != null || _webImageBytes != null
                            ? _successColor
                            : _primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            color: Colors.white,
                          ),
                          child: Center(child: _buildImagePreview()),
                        ),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isFileUploading
                                      ? null
                                      : _pickAndUploadFile,
                                  icon: _isFileUploading
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: _primaryColor,
                                          ),
                                        )
                                      : const Icon(Icons.file_upload, size: 24),
                                  label: Text(
                                    _isFileUploading
                                        ? 'Chargement...'
                                        : _selectedImageFile != null ||
                                              _webImageBytes != null
                                        ? 'Remplacer l\'image'
                                        : 'Choisir une image',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryColor,
                                    side: BorderSide(
                                      color: _primaryColor,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedImageFile != null ||
                                  _webImageBytes != null) ...[
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: _clearImageResults,
                                  icon: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          (_isImageAnalyzing ||
                              (_selectedImageFile == null &&
                                  _webImageBytes == null))
                          ? null
                          : _analyzeImage,
                      icon: _isImageAnalyzing
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.scanner, size: 24),
                      label: Text(
                        _isImageAnalyzing
                            ? 'Analyse en cours...'
                            : 'Scanner le document',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_imageResult != null) ...[
            const SizedBox(height: 24),
            if (_extractedImageText.isNotEmpty)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.text_snippet,
                              color: _primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Texte extrait de l\'image',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _primaryLightColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              _extractedImageText,
                              style: const TextStyle(fontSize: 15, height: 1.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: OcrResultWidget(
                  result: _imageResult!,
                  sourceType: 'IMAGE',
                  primaryColor: _primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history,
                        color: _primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historique des extractions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _primaryDarkColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_extractionHistory.length} opérations enregistrées',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_extractionHistory.isNotEmpty)
                Row(
                  children: [
                    IconButton(
                      onPressed: _isPdfGenerating ? null : _exportHistoryPdf,
                      icon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isPdfGenerating
                              ? Colors.grey.withOpacity(0.1)
                              : _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isPdfGenerating
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.picture_as_pdf,
                                color: _primaryColor,
                                size: 24,
                              ),
                      ),
                      tooltip: 'Exporter l\'historique en PDF',
                    ),
                    IconButton(
                      onPressed: () => _showClearHistoryDialog(),
                      icon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: _extractionHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Aucun historique',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Les extractions apparaîtront ici',
                        style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          DefaultTabController.of(context).animateTo(0);
                        },
                        icon: const Icon(Icons.text_fields),
                        label: const Text('Commencer une extraction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _extractionHistory.length,
                  itemBuilder: (context, index) {
                    final item = _extractionHistory[index];
                    return _buildHistoryItem(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final dateTime = item['datetime'] as DateTime;
    final type = item['type'] as String;
    final content = item['content'] as String;
    final success = item['success'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type == 'Texte' ? Icons.text_fields : Icons.image,
              color: _primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            content,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateTime(dateTime),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type == 'Texte' ? Icons.text_fields : Icons.image,
                            size: 12,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: success
                            ? _successColor.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            success ? Icons.check_circle : Icons.error,
                            size: 12,
                            color: success ? _successColor : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            success ? 'Succès' : 'Échec',
                            style: TextStyle(
                              fontSize: 12,
                              color: success ? _successColor : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _showDownloadPDFDialog(item);
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: _primaryColor,
                    size: 20,
                  ),
                ),
                tooltip: 'Télécharger en PDF',
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          onTap: () {
            _showHistoryDetails(item);
          },
        ),
      ),
    );
  }

  void _showDownloadPDFDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Exporter en PDF',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Voulez-vous exporter cette extraction en PDF ?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                item['content'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuccessAlert(
                        'PDF généré',
                        'Le fichier PDF a été généré avec succès',
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Vider l\'historique',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Êtes-vous sûr de vouloir supprimer tout l\'historique ?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible. Toutes les ${_extractionHistory.length} entrées seront supprimées.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _extractionHistory.clear();
                      });
                      Navigator.pop(context);
                      _showSuccessAlert(
                        'Historique vidé',
                        'Toutes les entrées ont été supprimées',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  void _showHistoryDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['type'] == 'Texte' ? Icons.text_fields : Icons.image,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de l\'extraction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryDarkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['type'] == 'Texte'
                            ? 'Extraction texte'
                            : 'Extraction image',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailItem('Type:', item['type']),
            _buildDetailItem(
              'Date & heure:',
              '${_formatDateTime(item['datetime'])} (${item['datetime'].hour}:${item['datetime'].minute.toString().padLeft(2, '0')})',
            ),
            _buildDetailItem('Contenu:', item['content']),
            _buildDetailItem(
              'Statut:',
              item['success'] ? 'Succès' : 'Échec',
              color: item['success'] ? _successColor : Colors.red,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDownloadPDFDialog(item);
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exporter PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteHistoryItem(item['id']);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteHistoryItem(String id) {
    setState(() {
      _extractionHistory.removeWhere((item) => item['id'] == id);
    });

    _showSuccessAlert('Supprimé', 'L\'élément a été supprimé de l\'historique');
  }
}

class _ScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final scanLineY = size.height * progress;
    canvas.drawLine(Offset(0, scanLineY), Offset(size.width, scanLineY), paint);

    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final cornerSize = 20.0;
    final animatedCornerSize = cornerSize * (0.5 + 0.5 * progress);

    canvas.drawLine(Offset(0, 0), Offset(animatedCornerSize, 0), cornerPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, animatedCornerSize), cornerPaint);

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - animatedCornerSize, 0),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, animatedCornerSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(animatedCornerSize, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - animatedCornerSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - animatedCornerSize, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - animatedCornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
