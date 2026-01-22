// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  Timer? _successTimer;

  final Color primaryBlue = const Color.fromARGB(255, 25, 47, 242);

  // Fonction pour afficher l'alerte style SweetAlert améliorée
  void _showSweetAlert(
    BuildContext context,
    String message, {
    bool isError = true,
    bool autoClose = false,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) {
    OverlayEntry? overlayEntry;

    // Fermer les alertes précédentes si elles existent
    _successTimer?.cancel();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: () {
                overlayEntry?.remove();
              },
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icone animée
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isError
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isError ? Icons.error_outline : Icons.check_circle,
                            color: isError ? Colors.red : Colors.green,
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Titre avec style amélioré
                        Text(
                          isError ? 'Erreur' : 'Succès',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: isError ? Colors.red : Colors.green,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Ligne décorative
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isError ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Message avec meilleure typographie
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Bouton amélioré
                        SizedBox(
                          width: 140,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              overlayEntry?.remove();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isError
                                  ? Colors.red
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-fermeture pour les succès
    if (autoClose && !isError) {
      _successTimer = Timer(autoCloseDuration, () {
        overlayEntry?.remove();
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Tentative de connexion: ${_emailController.text.trim()}');

      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('✅ Connexion API réussie');

      if (!mounted) return;

      await authService.getCurrentUser();
      print('✅ Informations utilisateur récupérées');

      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token non reçu');
      }

      print('✅ Token valide reçu');

      // Afficher l'alerte de succès améliorée
      _showSweetAlert(
        // ignore: use_build_context_synchronously
        context,
        'Connexion réussie !\nRedirection vers le dashboard...',
        isError: false,
        autoClose: true,
        autoCloseDuration: const Duration(milliseconds: 1800),
      );

      // Rediriger après un délai
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Animation de transition
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print('❌ Erreur de connexion: $e');

      if (mounted) {
        // Afficher l'alerte d'erreur améliorée
        _showSweetAlert(context, _getErrorMessage(e.toString()), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    print('🔍 Analyse erreur: $error');

    // Gestion des erreurs spécifiques avec des messages plus clairs
    if (error.contains('401') ||
        error.contains('incorrect') ||
        error.contains('Invalid credentials') ||
        error.contains('identifiants')) {
      return 'Les identifiants sont incorrects.\nVeuillez vérifier votre email et mot de passe.';
    } else if (error.contains('SocketException') ||
        error.contains('Network is unreachable') ||
        error.contains('Failed host lookup')) {
      return 'Connexion internet indisponible.\nVérifiez votre connexion réseau.';
    } else if (error.contains('403') || error.contains('Compte désactivé')) {
      return 'Votre compte a été désactivé.\nContactez l\'administrateur.';
    } else if (error.contains('404') || error.contains('not found')) {
      return 'Utilisateur non trouvé.\nVérifiez votre email ou créez un compte.';
    } else if (error.contains('500') ||
        error.contains('Internal Server Error')) {
      return 'Erreur technique du serveur.\nVeuillez réessayer dans quelques instants.';
    } else if (error.contains('timeout') || error.contains('Timeout')) {
      return 'Le serveur met trop de temps à répondre.\nVérifiez votre connexion ou réessayez.';
    } else if (error.contains('Token non reçu')) {
      return 'Problème d\'authentification.\nVeuillez vous reconnecter.';
    } else if (error.contains('CORS') || error.contains('Access-Control')) {
      return 'Erreur de configuration serveur.\nContactez le support technique.';
    }

    final errorLower = error.toLowerCase();
    if (errorLower.contains('email') && errorLower.contains('exist')) {
      return 'Cet email n\'existe pas dans notre système.\nVérifiez l\'adresse ou inscrivez-vous.';
    }
    if (errorLower.contains('password') ||
        errorLower.contains('mot de passe')) {
      return 'Mot de passe incorrect.\nEssayez de réinitialiser votre mot de passe.';
    }

    return 'Une erreur inattendue est survenue.\nVeuillez réessayer plus tard.';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _successTimer?.cancel();
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
                // Logo avec animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 28),

                // Titre avec gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryBlue, Color.fromARGB(255, 76, 110, 245)],
                  ).createShader(bounds),
                  child: Text(
                    'Live Commerce',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Sous-titre
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: primaryBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Format d\'email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: primaryBlue,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 caractères requis';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                            shadowColor: primaryBlue.withOpacity(0.4),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isLoading ? 'Connexion...' : 'Se connecter',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Séparateur
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Ou continuer avec',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Lien vers inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nouveau sur Live Commerce ? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
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
