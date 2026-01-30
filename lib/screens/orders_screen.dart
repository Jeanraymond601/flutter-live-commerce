import 'package:flutter/material.dart';

class ExtractionScreen extends StatefulWidget {
  const ExtractionScreen({super.key});

  @override
  State<ExtractionScreen> createState() => _ExtractionScreenState();
}

class _ExtractionScreenState extends State<ExtractionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _formData;
  String? _imageData;

  final List<Map<String, String>> _history = [];

  // =========================
  // SIMULATION EXTRACTION
  // =========================
  void _extractFromForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _history.insert(0, {
          'type': 'Formulaire',
          'result': _formData!,
          'datetime': DateTime.now().toString(),
        });
      });
    }
  }

  void _extractFromImage() {
    setState(() {
      // Simulation extraction image
      _imageData = 'Texte extrait de l\'image';
      _history.insert(0, {
        'type': 'Image',
        'result': _imageData!,
        'datetime': DateTime.now().toString(),
      });
    });
  }

  // =========================
  // WIDGETS
  // =========================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Extraction'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // SECTION 1: FORMULAIRE
            // =========================
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extraction depuis Formulaire',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Entrez du texte',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                        onSaved: (value) => _formData = value,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _extractFromForm,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Extraire'),
                    ),
                    if (_formData != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Résultat: $_formData',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // =========================
            // SECTION 2: IMAGE
            // =========================
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extraction depuis Image',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _extractFromImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Importer / Extraire Image'),
                    ),
                    if (_imageData != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Résultat: $_imageData',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // =========================
            // SECTION 3: HISTORIQUE
            // =========================
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique des Extractions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_history.isEmpty)
                      Center(
                        child: Text(
                          'Aucune extraction',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 16, thickness: 1),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return ListTile(
                            leading: Icon(
                              item['type'] == 'Formulaire'
                                  ? Icons.note_alt
                                  : Icons.image,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(item['result']!),
                            subtitle: Text(item['datetime']!),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
