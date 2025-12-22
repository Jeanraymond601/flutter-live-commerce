import 'dart:convert';

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final vendor = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentVendor;
    _name = vendor?.name;
    _email = vendor?.email;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final vendor = authService.currentVendor;
    if (vendor == null) {
      setState(() {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
      });
      return;
    }
    final token = await authService.getToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'Token d\'authentification manquant';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${Constants.apiBaseUrl}/vendors/${vendor.id}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': _name, 'email': _email}),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
        // Mettre à jour localement via une méthode dédiée dans AuthService
        authService.updateCurrentVendor(name: _name, email: _email);
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['detail'] ?? 'Erreur serveur';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau: $e';
      });
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_errorMessage != null) ...{
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                },
                TextFormField(
                  initialValue: _name,
                  decoration: inputDecoration.copyWith(labelText: 'Nom'),
                  onSaved: (value) => _name = value,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Champ requis'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _email,
                  decoration: inputDecoration.copyWith(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Champ requis';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('Enregistrer'),
                      ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Se déconnecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
