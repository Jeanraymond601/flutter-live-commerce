import 'package:flutter/material.dart';
import '../models/ocr_model.dart';

class OcrResultWidget extends StatelessWidget {
  final OcrModel result;
  final String sourceType;
  final Color? primaryColor;

  const OcrResultWidget({
    super.key,
    required this.result,
    required this.sourceType,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = primaryColor ?? Colors.blue;
    final Color lightColor = primary.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, lightColor],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primary, lightColor),
            const SizedBox(height: 16),
            if (result.name != null && result.name != null)
              _buildInfoRow(Icons.person, 'Nom', result.name!, primary),
            if (result.phone != null && result.phone != null)
              _buildInfoRow(Icons.phone, 'Téléphone', result.phone!, primary),
            if (result.address != null && result.address != null)
              _buildInfoRow(
                Icons.location_on,
                'Adresse',
                result.address!,
                primary,
              ),
            const SizedBox(height: 16),
            _buildConfidenceIndicator(result.confidence, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color lightColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(_getSourceIcon(sourceType), size: 14, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                _getSourceLabel(sourceType),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, size: 12, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'IA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence, Color color) {
    final Color progressColor = _getConfidenceColor(confidence);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confiance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey[200],
            color: progressColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source.toUpperCase()) {
      case 'LIVE':
        return Icons.live_tv;
      case 'TEXT':
        return Icons.text_fields;
      case 'IMAGE':
        return Icons.image;
      default:
        return Icons.help_outline;
    }
  }

  String _getSourceLabel(String source) {
    switch (source.toUpperCase()) {
      case 'LIVE':
        return 'Analyse Live';
      case 'TEXT':
        return 'Texte';
      case 'IMAGE':
        return 'OCR Image';
      default:
        return 'Inconnu';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }
}
