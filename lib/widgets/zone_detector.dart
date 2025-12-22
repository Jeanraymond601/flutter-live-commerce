// lib/widgets/zone_detector.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/zone.dart';

class ZoneDetector extends StatefulWidget {
  final String initialAddress;
  final ValueChanged<String>? onZoneDetected;
  final ValueChanged<ZoneDetection>? onDetectionComplete;
  final bool autoDetect;
  final bool showSuggestions;
  final TextStyle? textStyle;
  final String? hintText;
  final bool enabled;

  const ZoneDetector({
    super.key,
    this.initialAddress = '',
    this.onZoneDetected,
    this.onDetectionComplete,
    this.autoDetect = true,
    this.showSuggestions = true,
    this.textStyle,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<ZoneDetector> createState() => _ZoneDetectorState();
}

class _ZoneDetectorState extends State<ZoneDetector> {
  late TextEditingController _addressController;
  late FocusNode _addressFocusNode;
  String _detectedZone = '';
  bool _isDetecting = false;
  bool _showSuggestions = false;
  List<ZoneSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _addressFocusNode = FocusNode();

    if (widget.initialAddress.isNotEmpty) {
      _detectZone(widget.initialAddress);
    }

    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus && widget.autoDetect) {
        _detectZone(_addressController.text);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _detectZone(String address) async {
    if (address.isEmpty || !widget.enabled) return;

    setState(() {
      _isDetecting = true;
      _detectedZone = '';
    });

    try {
      // Simulation de détection (à remplacer par l'appel API)
      await Future.delayed(const Duration(milliseconds: 500));

      final detectedZone = _simulateZoneDetection(address);
      final detection = ZoneDetection.simple(address, detectedZone);

      setState(() {
        _detectedZone = detectedZone;
        _isDetecting = false;
        _suggestions = _generateSuggestions(detectedZone);
      });

      widget.onZoneDetected?.call(detectedZone);
      widget.onDetectionComplete?.call(detection);
    } catch (e) {
      setState(() {
        _isDetecting = false;
        _detectedZone = 'Erreur de détection';
      });
    }
  }

  String _simulateZoneDetection(String address) {
    final addressLower = address.toLowerCase();

    // Détection par code postal
    for (final entry in Constants.postalCodeToZone.entries) {
      if (addressLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Détection par ville
    for (final zone in Constants.commonZonesMadagascar) {
      if (addressLower.contains(zone.toLowerCase())) {
        return zone;
      }
    }

    // Détection par quartier
    if (addressLower.contains('analakely')) {
      return 'Antananarivo - Analakely';
    } else if (addressLower.contains('isotry')) {
      return 'Antananarivo - Isotry';
    } else if (addressLower.contains('andohalo')) {
      return 'Antananarivo - Andohalo';
    }

    // Fallback : extraire les premiers mots
    final words = address.split(' ').where((word) => word.length > 2).toList();
    if (words.length >= 2) {
      return '${words[0]} ${words[1]}';
    }

    return 'Zone Madagascar';
  }

  List<ZoneSuggestion> _generateSuggestions(String detectedZone) {
    if (!widget.showSuggestions) return [];

    final suggestions = <ZoneSuggestion>[];

    // Chercher des zones similaires
    for (final zone in Constants.commonZonesMadagascar) {
      final similarity = _calculateSimilarity(detectedZone, zone);
      if (similarity > 0.3) {
        suggestions.add(
          ZoneSuggestion(
            zone: zone,
            score: similarity,
            reason: _getSuggestionReason(zone, detectedZone),
          ),
        );
      }
    }

    // Trier par score décroissant
    suggestions.sort((a, b) => b.score.compareTo(a.score));

    return suggestions.take(3).toList();
  }

  double _calculateSimilarity(String zone1, String zone2) {
    final z1 = zone1.toLowerCase();
    final z2 = zone2.toLowerCase();

    if (z1 == z2) return 1.0;
    if (z1.contains(z2) || z2.contains(z1)) return 0.8;

    // Calculer la similarité de Jaccard
    final set1 = z1.split(' ').toSet();
    final set2 = z2.split(' ').toSet();
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;

    return intersection / union;
  }

  String _getSuggestionReason(String suggestedZone, String detectedZone) {
    if (suggestedZone.toLowerCase().contains(detectedZone.toLowerCase())) {
      return 'Correspondance exacte';
    } else if (suggestedZone.split(' - ')[0] == detectedZone.split(' - ')[0]) {
      return 'Même ville';
    } else {
      return 'Zone proche';
    }
  }

  void _selectSuggestion(ZoneSuggestion suggestion) {
    setState(() {
      _detectedZone = suggestion.zone;
      _showSuggestions = false;
    });

    widget.onZoneDetected?.call(suggestion.zone);
    widget.onDetectionComplete?.call(
      ZoneDetection.simple(_addressController.text, suggestion.zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ d'adresse
        TextField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          enabled: widget.enabled,
          style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Entrez l\'adresse complète',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.defaultRadius),
            ),
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _isDetecting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _detectZone(_addressController.text),
                    tooltip: 'Détecter la zone',
                  ),
          ),
          maxLines: 3,
          minLines: 1,
          onChanged: (value) {
            if (widget.autoDetect && value.length > 10) {
              _debounceDetection(value);
            }
            setState(() {
              _showSuggestions = value.isNotEmpty;
            });
          },
          onSubmitted: (value) {
            _detectZone(value);
            _addressFocusNode.unfocus();
          },
        ),

        const SizedBox(height: 8),

        // Zone détectée
        if (_detectedZone.isNotEmpty) ...[
          _buildDetectedZoneCard(context),
          const SizedBox(height: 8),
        ],

        // Suggestions
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          _buildSuggestionsList(),
          const SizedBox(height: 8),
        ],

        // Indicateur de qualité
        if (_detectedZone.isNotEmpty && !_isDetecting) ...[
          _buildQualityIndicator(),
        ],
      ],
    );
  }

  Widget _buildDetectedZoneCard(BuildContext context) {
    return Card(
          color: Colors.blue.withOpacity(0.05),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zone détectée',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _detectedZone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.content_copy,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    // Copier dans le presse-papier
                    // Clipboard.setData(ClipboardData(text: _detectedZone));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zone copiée dans le presse-papier'),
                      ),
                    );
                  },
                  tooltip: 'Copier la zone',
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.5, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildSuggestionsList() {
    return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                ..._suggestions.map((suggestion) {
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: suggestion.isHighScore
                            ? Colors.green.withOpacity(0.1)
                            : suggestion.isMediumScore
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          suggestion.scoreDisplay,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: suggestion.isHighScore
                                ? Colors.green
                                : suggestion.isMediumScore
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    title: Text(suggestion.zone),
                    subtitle: suggestion.reason != null
                        ? Text(
                            suggestion.reason!,
                            style: const TextStyle(fontSize: 11),
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onTap: () => _selectSuggestion(suggestion),
                  );
                }),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.3, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildQualityIndicator() {
    final confidence = _calculateConfidence(
      _detectedZone,
      _addressController.text,
    );

    return Row(
      children: [
        Icon(
          _getConfidenceIcon(confidence) as IconData?,
          size: 16,
          color: _getConfidenceColor(confidence),
        ),
        const SizedBox(width: 8),
        Text(
          _getConfidenceText(confidence),
          style: TextStyle(
            fontSize: 12,
            color: _getConfidenceColor(confidence),
          ),
        ),
        const Spacer(),
        Text(
          'Basé sur ${_addressController.text.split(' ').length} mots',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  String _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return 'check_circle';
    if (confidence >= 0.5) return 'warning';
    return 'error';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 0.8) return 'Haute confiance';
    if (confidence >= 0.5) return 'Confiance moyenne';
    return 'Faible confiance';
  }

  double _calculateConfidence(String zone, String address) {
    // Calcul simple de confiance basé sur la longueur et la présence de mots-clés
    final addressLower = address.toLowerCase();
    final zoneLower = zone.toLowerCase();

    var confidence = 0.5; // Base

    // Bonus pour correspondance exacte
    if (addressLower.contains(zoneLower)) confidence += 0.3;

    // Bonus pour code postal
    if (RegExp(r'\b\d{3}\b').hasMatch(address)) confidence += 0.2;

    // Bonus pour nom de ville connu
    for (final city in ['antananarivo', 'toamasina', 'mahajanga', 'toliara']) {
      if (addressLower.contains(city)) confidence += 0.1;
    }

    // Bonus pour longueur d'adresse
    if (address.length > 30) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  Timer? _detectionTimer;

  void _debounceDetection(String value) {
    _detectionTimer?.cancel();
    _detectionTimer = Timer(
      const Duration(milliseconds: Constants.debounceDelay),
      () => _detectZone(value),
    );
  }
}

// Version simplifiée pour les formulaires
class SimpleZoneDetector extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool enabled;
  final TextStyle? style;

  const SimpleZoneDetector({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ZoneDetector(
      initialAddress: initialValue ?? '',
      onZoneDetected: onChanged,
      autoDetect: true,
      showSuggestions: false,
      textStyle: style,
      hintText: hintText ?? 'Adresse pour détection zone',
      enabled: enabled,
    );
  }
}
