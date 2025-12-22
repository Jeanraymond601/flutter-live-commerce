// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/seller_profile.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/settings_card.dart';
import '../services/seller_service.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final SellerService _sellerService = SellerService();
  late SellerProfile _sellerProfile;

  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'Anglais', 'Espagnol', 'Arabe'];

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  Future<void> _loadSellerProfile() async {
    try {
      final profile = await _sellerService.getSellerProfile();
      setState(() {
        _sellerProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      // Charger un profil par défaut en cas d'erreur
      setState(() {
        _sellerProfile = SellerProfile.defaultProfile();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        // Mettre à jour l'image de profil
        final success = await _sellerService.updateProfileImage(
          pickedFile.path,
        );
        if (success && mounted) {
          _loadSellerProfile(); // Recharger le profil
        }
      }
    } catch (e) {
      print('Erreur lors du choix de l\'image: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkModeEnabled = value;
      // Ici, vous pouvez intégrer avec un package de gestion de thème
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      // Sauvegarder le paramètre
    });
  }

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedLanguage = newValue;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _sellerService.logout();
              if (success && mounted) {
                // Naviguer vers l'écran de connexion
                // Navigator.pushAndRemoveUntil(...)
              }
            },
            child: const Text(
              'DÉCONNEXION',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    // Logique de navigation selon la route
    switch (route) {
      case 'products':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsScreen()));
        break;
      case 'livestreams':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => LiveStreamsScreen()));
        break;
      case 'orders':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersScreen()));
        break;
      case 'stats':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen()));
        break;
      case 'support':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SupportScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode
            ? Colors.grey[900]
            : const Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            color: isDarkMode ? Colors.white : const Color(0xFF2196F3),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // En-tête du profil
              ProfileHeader(
                sellerProfile: _sellerProfile,
                onImageTap: _pickProfileImage,
              ),

              const SizedBox(height: 20),

              // Informations personnelles
              ProfileInfoCard(
                sellerProfile: _sellerProfile,
                onEditPressed: () {
                  // Naviguer vers l'édition du profil
                },
              ),

              const SizedBox(height: 20),

              // Facebook Connection
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Actions rapides
              QuickActionsGrid(onActionSelected: _navigateTo),

              const SizedBox(height: 20),

              // Paramètres
              SettingsCard(
                darkModeEnabled: _darkModeEnabled,
                notificationsEnabled: _notificationsEnabled,
                selectedLanguage: _selectedLanguage,
                languages: _languages,
                onDarkModeChanged: _toggleDarkMode,
                onNotificationsChanged: _toggleNotifications,
                onLanguageChanged: _changeLanguage,
              ),

              const SizedBox(height: 20),

              // Sécurité et déconnexion
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Naviguer vers le changement de mot de passe
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[100],
                            foregroundColor: isDarkMode
                                ? Colors.white
                                : Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Changer mon mot de passe'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Déconnexion'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
