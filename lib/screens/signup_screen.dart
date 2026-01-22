// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _selectedCountryCode = '+261'; // Madagascar par défaut
  Timer? _successTimer;

  final Color primaryBlue = const Color.fromARGB(255, 25, 47, 242);

  // Liste des pays avec Madagascar en premier
  final List<Map<String, String>> countries = [
    {'code': '+261', 'flag': '🇲🇬', 'name': 'Madagascar'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+212', 'flag': '🇲🇦', 'name': 'Maroc'},
    {'code': '+213', 'flag': '🇩🇿', 'name': 'Algérie'},
    {'code': '+216', 'flag': '🇹🇳', 'name': 'Tunisie'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA/Canada'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Allemagne'},
    {'code': '+34', 'flag': '🇪🇸', 'name': 'Espagne'},
    {'code': '+39', 'flag': '🇮🇹', 'name': 'Italie'},
    {'code': '+32', 'flag': '🇧🇪', 'name': 'Belgique'},
    {'code': '+41', 'flag': '🇨🇭', 'name': 'Suisse'},
    {'code': '+31', 'flag': '🇳🇱', 'name': 'Pays-Bas'},
    {'code': '+351', 'flag': '🇵🇹', 'name': 'Portugal'},
    {'code': '+90', 'flag': '🇹🇷', 'name': 'Turquie'},
    {'code': '+7', 'flag': '🇷🇺', 'name': 'Russie'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'Chine'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japon'},
    {'code': '+82', 'flag': '🇰🇷', 'name': 'Corée du Sud'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'Inde'},
    {'code': '+55', 'flag': '🇧🇷', 'name': 'Brésil'},
    {'code': '+54', 'flag': '🇦🇷', 'name': 'Argentine'},
    {'code': '+20', 'flag': '🇪🇬', 'name': 'Égypte'},
    {'code': '+27', 'flag': '🇿🇦', 'name': 'Afrique du Sud'},
    {'code': '+234', 'flag': '🇳🇬', 'name': 'Nigeria'},
    {'code': '+254', 'flag': '🇰🇪', 'name': 'Kenya'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australie'},
    {'code': '+64', 'flag': '🇳🇿', 'name': 'Nouvelle-Zélande'},
  ];

  // Fonction pour afficher l'alerte style SweetAlert
  void _showSweetAlert(
    BuildContext context,
    String message, {
    bool isError = true,
    bool autoClose = false,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) {
    OverlayEntry? overlayEntry;

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

                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isError ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        const SizedBox(height: 20),

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

    if (autoClose && !isError) {
      _successTimer = Timer(autoCloseDuration, () {
        overlayEntry?.remove();
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('📝 Début de l\'inscription: ${_emailController.text.trim()}');

      final authService = Provider.of<AuthService>(context, listen: false);

      // Construire le numéro de téléphone complet
      String fullPhoneNumber = '';
      if (_phoneController.text.trim().isNotEmpty) {
        fullPhoneNumber =
            '$_selectedCountryCode${_phoneController.text.trim()}';
        print('📱 Numéro de téléphone complet: $fullPhoneNumber');
      }

      // Inscription
      print('📤 Envoi des données d\'inscription...');
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: 'Vendeur',
        phone: fullPhoneNumber.isEmpty ? null : fullPhoneNumber,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        companyName: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
      );

      print('✅ Inscription réussie sur l\'API');

      if (!mounted) return;

      // Connexion automatique
      print('🔐 Connexion automatique après inscription...');
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('✅ Connexion automatique réussie');

      // Récupérer les infos utilisateur
      await authService.getCurrentUser();
      print('✅ Informations utilisateur récupérées');

      // Vérifier le token
      final token = await authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token non reçu après inscription');
      }

      print('✅ Token valide: ${token.substring(0, 20)}...');

      // Afficher l'alerte de succès
      _showSweetAlert(
        context,
        'Inscription réussie !\nVotre compte a été créé avec succès.',
        isError: false,
        autoClose: true,
        autoCloseDuration: const Duration(milliseconds: 2000),
      );

      // Redirection
      await Future.delayed(const Duration(milliseconds: 2200));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');

      if (mounted) {
        _showSweetAlert(context, _getErrorMessage(e.toString()), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    print('🔍 Analyse erreur inscription: $error');

    final errorLower = error.toLowerCase();

    if (errorLower.contains('email') &&
        (errorLower.contains('already') ||
            errorLower.contains('exists') ||
            errorLower.contains('déjà') ||
            errorLower.contains('existe'))) {
      return 'Cet email est déjà utilisé.\nConnectez-vous ou utilisez un autre email.';
    }

    if (errorLower.contains('password') && errorLower.contains('weak') ||
        errorLower.contains('simple') ||
        errorLower.contains('court')) {
      return 'Mot de passe trop faible.\nUtilisez au moins 8 caractères avec chiffres et lettres.';
    }

    if (errorLower.contains('password') && errorLower.contains('6')) {
      return 'Le mot de passe doit contenir\nau moins 6 caractères.';
    }

    if (errorLower.contains('invalid') && errorLower.contains('email')) {
      return 'Format d\'email invalide.';
    }

    if (errorLower.contains('phone') && errorLower.contains('invalid')) {
      return 'Format de téléphone invalide.\nVérifiez le numéro avec l\'indicatif.';
    }

    if (errorLower.contains('name') && errorLower.contains('required')) {
      return 'Le nom complet est obligatoire.';
    }

    if (errorLower.contains('network') ||
        errorLower.contains('socket') ||
        errorLower.contains('unreachable') ||
        errorLower.contains('failed') ||
        errorLower.contains('timeout')) {
      return 'Problème de connexion.\nVérifiez votre internet et réessayez.';
    }

    if (errorLower.contains('400') || errorLower.contains('bad request')) {
      return 'Données invalides.\nVérifiez les informations saisies.';
    }

    if (errorLower.contains('409') || errorLower.contains('conflict')) {
      return 'Ce compte existe déjà.\nEssayez de vous connecter.';
    }

    if (errorLower.contains('500') || errorLower.contains('internal server')) {
      return 'Erreur serveur.\nVeuillez réessayer dans quelques minutes.';
    }

    if (errorLower.contains('token non reçu')) {
      return 'Problème d\'authentification.\nEssayez de vous connecter manuellement.';
    }

    if (error.contains('Exception: ') && error.length > 11) {
      final specificError = error.substring(11);
      if (specificError.isNotEmpty) {
        return specificError;
      }
    }

    return 'Erreur lors de l\'inscription.\nVeuillez réessayer.';
  }

  // Widget pour le sélecteur de pays - CORRIGÉ
  Widget _buildCountrySelector() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          iconSize: 30,
          elevation: 16,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          isExpanded: true, // Important pour éviter le débordement
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountryCode = newValue;
              });
            }
          },
          items: countries.map<DropdownMenuItem<String>>((
            Map<String, String> country,
          ) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(country['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${country['code']} ${country['name']}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
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
                // Logo
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
                  child: const Icon(
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
                  'Créez votre compte vendeur',
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
                      // Nom complet
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet *',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: Icon(
                            Icons.person_outline,
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
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          if (value.trim().length < 2) {
                            return 'Minimum 2 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
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
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
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
                          labelText: 'Mot de passe *',
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

                      const SizedBox(height: 20),

                      // Nom de l'entreprise
                      TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'entreprise',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: Icon(
                            Icons.business_outlined,
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
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 20),

                      // Téléphone avec sélecteur de pays
                      Row(
                        children: [
                          // Sélecteur de pays avec largeur fixe
                          // ignore: sized_box_for_whitespace
                          Container(width: 140, child: _buildCountrySelector()),

                          const SizedBox(width: 12),

                          // Champ téléphone
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Téléphone',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: primaryBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
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
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Adresse
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adresse',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signUp(),
                      ),

                      const SizedBox(height: 28),

                      // Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: primaryBlue,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Les champs marqués d\'un * sont obligatoires',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Bouton d'inscription
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
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
                                  _isLoading
                                      ? 'Création...'
                                      : 'Créer mon compte',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Lien vers connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Déjà un compte ? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Text(
                                'Se connecter',
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
