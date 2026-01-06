// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final Color primaryBlue = const Color.fromARGB(255, 25, 47, 242);

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📝 Début de l\'inscription: ${_emailController.text.trim()}');

      final authService = Provider.of<AuthService>(context, listen: false);

      // Étape 1: Inscription
      print('📤 Envoi des données d\'inscription...');
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: 'Vendeur',
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        companyName: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
      );

      print('✅ Inscription réussie sur l\'API');

      if (!mounted) return;

      // Étape 2: Connexion automatique
      print('🔐 Connexion automatique après inscription...');
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('✅ Connexion automatique réussie');

      // Étape 3: Récupérer les infos utilisateur
      await authService.getCurrentUser();
      print('✅ Informations utilisateur récupérées');

      // Vérifier le token
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token non reçu après inscription');
      }

      print('✅ Token valide: ${token.substring(0, 20)}...');

      // Étape 4: Redirection
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');

      String errorMessage = _getErrorMessage(e.toString());

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
        });

        // Afficher un snackbar en plus
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    print('🔍 Analyse erreur inscription: $error');

    // Messages d'erreur courants pour l'inscription
    final errorLower = error.toLowerCase();

    if (errorLower.contains('email') &&
        (errorLower.contains('already') ||
            errorLower.contains('exists') ||
            errorLower.contains('déjà') ||
            errorLower.contains('existe'))) {
      return 'Cet email est déjà utilisé. Connectez-vous ou utilisez un autre email.';
    }

    if (errorLower.contains('password') && errorLower.contains('weak') ||
        errorLower.contains('simple') ||
        errorLower.contains('court')) {
      return 'Mot de passe trop faible. Utilisez au moins 8 caractères avec chiffres et lettres.';
    }

    if (errorLower.contains('password') && errorLower.contains('6')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    if (errorLower.contains('invalid') && errorLower.contains('email')) {
      return 'Format d\'email invalide';
    }

    if (errorLower.contains('phone') && errorLower.contains('invalid')) {
      return 'Format de téléphone invalide';
    }

    if (errorLower.contains('name') && errorLower.contains('required')) {
      return 'Le nom est obligatoire';
    }

    if (errorLower.contains('network') ||
        errorLower.contains('socket') ||
        errorLower.contains('unreachable') ||
        errorLower.contains('failed') ||
        errorLower.contains('timeout')) {
      return 'Problème de connexion. Vérifiez votre internet et réessayez.';
    }

    if (errorLower.contains('400') || errorLower.contains('bad request')) {
      return 'Données invalides. Vérifiez les informations saisies.';
    }

    if (errorLower.contains('409') || errorLower.contains('conflict')) {
      return 'Ce compte existe déjà';
    }

    if (errorLower.contains('500') || errorLower.contains('internal server')) {
      return 'Erreur serveur. Veuillez réessayer dans quelques minutes.';
    }

    if (errorLower.contains('token non reçu')) {
      return 'Problème d\'authentification après inscription. Essayez de vous connecter manuellement.';
    }

    // Extraire le message d'erreur spécifique si possible
    if (error.contains('Exception: ') && error.length > 11) {
      final specificError = error.substring(11);
      if (specificError.isNotEmpty) {
        return specificError;
      }
    }

    return 'Erreur lors de l\'inscription. Veuillez réessayer.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Titre
                Text(
                  'Live Commerce',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Créez votre compte vendeur',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 32),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nom complet
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet *',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          if (value.trim().length < 2) {
                            return 'Le nom doit contenir au moins 2 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Format d\'email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe *',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nom de l'entreprise
                      TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'entreprise',
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 16),

                      // Téléphone
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 16),

                      // Adresse
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adresse',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signUp(),
                      ),

                      const SizedBox(height: 32),

                      // Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Les champs marqués d\'un * sont obligatoires',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton d'inscription
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Créer mon compte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Lien vers connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Déjà un compte ? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              // Utiliser pushReplacementNamed si vous voulez remplacer l'écran
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
