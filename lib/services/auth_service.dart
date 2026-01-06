// lib/services/auth_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vendor.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // ÉTAT DE LA SESSION
  Vendor? _currentVendor;
  String? _authToken;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Constructeur sans paramètre
  AuthService();

  // GETTERS
  Vendor? get currentVendor => _currentVendor;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _currentVendor != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // RÔLES
  bool get isVendor => _currentVendor?.role.toLowerCase() == 'vendeur';
  bool get isDelivery => _currentVendor?.role.toLowerCase() == 'livreur';
  bool get isAdmin => _currentVendor?.role.toLowerCase() == 'admin';

  // ================================
  // INITIALISATION SHARED PREFERENCES
  // ================================
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ================================
  // INITIALISATION DE LA SESSION
  // ================================
  Future<void> initializeSession() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Initialisation de la session...');
      await _initPrefs();

      // 1. Récupérer le token (priorité Secure Storage)
      String? token = await _secureStorage.read(key: 'jwt_token');

      // CORRECTION ICI: Vérifier si token est null ou vide
      if (token == null || token.isEmpty) {
        // 2. Fallback vers SharedPreferences
        token = _prefs?.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          print('🔁 Token récupéré depuis SharedPreferences');
        }
      }

      if (token != null && token.isNotEmpty) {
        print('📋 Token trouvé: OUI (${token.length} caractères)');
        _authToken = token;

        // 3. Récupérer les infos utilisateur
        await _fetchCurrentUser();

        if (_currentVendor != null) {
          print('✅ Session restaurée pour: ${_currentVendor!.email}');
        } else {
          print('⚠️ Token valide mais utilisateur non récupéré');
          await _clearSession();
        }
      } else {
        print('ℹ️ Aucune session existante');
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ Erreur initialisation session: $e');
      await _clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // STOCKAGE DU TOKEN
  // ================================
  Future<void> _storeToken(String token) async {
    try {
      // 1. Stocker dans Secure Storage
      await _secureStorage.write(key: 'jwt_token', value: token);
      print('💾 Token stocké dans SecureStorage');

      // 2. Stocker dans SharedPreferences pour compatibilité
      await _initPrefs(); // S'assurer que _prefs est initialisé
      await _prefs?.setString('auth_token', token);
      print('💾 Token stocké dans SharedPreferences');

      // 3. Mettre à jour en mémoire
      _authToken = token;

      // 4. Vérification
      final storedToken = await _secureStorage.read(key: 'jwt_token');
      if (storedToken == token) {
        print('✓ Token vérifié dans SecureStorage');
      }
    } catch (e) {
      print('❌ Erreur stockage token: $e');
      rethrow;
    }
  }

  // ================================
  // STOCKAGE DES INFOS UTILISATEUR
  // ================================
  Future<void> _storeUserInfo(Map<String, dynamic> userData) async {
    try {
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
      print('💾 User info stored');
    } catch (e) {
      print('❌ Erreur stockage user info: $e');
    }
  }

  // ================================
  // CONNEXION
  // ================================
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔐 Tentative de connexion: $email');

      final url = Uri.parse('${Constants.getApiUrl()}${Constants.authLogin}');
      final body = jsonEncode({'email': email, 'password': password});

      print('🌐 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📡 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 1. Récupérer le token
        final token = data['access_token'] ?? data['token'];
        if (token == null || token.isEmpty) {
          throw Exception('Token non reçu dans la réponse');
        }

        print('🔑 Token reçu (${token.length} caractères)');

        // 2. Stocker le token
        await _storeToken(token);

        // 3. Stocker les données initiales
        await _storeUserInfo(data);

        // 4. Récupérer les informations complètes de l'utilisateur
        await _fetchCurrentUser();

        print(
          '✅ Connexion réussie: ${_currentVendor!.email} (${_currentVendor!.role})',
        );

        // 5. Vérification finale
        final savedToken = await getToken();
        if (savedToken != null) {
          print('✓ Token sauvegardé avec succès');
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMsg =
            error['detail'] ??
            error['message'] ??
            'Échec de la connexion (${response.statusCode})';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Erreur connexion: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // INSCRIPTION
  // ================================
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? address,
    String? companyName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📝 Tentative d\'inscription: $email');
      await _initPrefs();

      final url = Uri.parse(
        '${Constants.getApiUrl()}${Constants.authRegister}',
      );
      final body = jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'telephone': phone,
        if (address != null && address.isNotEmpty) 'adresse': address,
        if (companyName != null && companyName.isNotEmpty)
          'company_name': companyName,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📡 Réponse inscription: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Connexion automatique
        await signIn(email, password);
        print('✅ Inscription et connexion réussies');
      } else {
        final error = jsonDecode(response.body);
        final errorMsg =
            error['detail'] ??
            error['message'] ??
            'Échec de l\'inscription (${response.statusCode})';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Erreur inscription: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // DÉCONNEXION
  // ================================
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🚪 Déconnexion en cours...');
      await _clearSession();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // RÉCUPÉRATION UTILISATEUR COURANT
  // ================================
  Future<void> getCurrentUser() async {
    if (_authToken == null) {
      print('⚠️ Aucun token pour récupérer l\'utilisateur');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _fetchCurrentUser();
    } catch (e) {
      print('❌ Erreur récupération utilisateur: $e');
      // Si token invalide, déconnecter
      if (e.toString().contains('401') ||
          e.toString().contains('token') ||
          e.toString().contains('expir') ||
          e.toString().contains('invalid')) {
        await _clearSession();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // RÉCUPÉRATION DEPUIS L'API
  // ================================
  Future<void> _fetchCurrentUser() async {
    if (_authToken == null) {
      print('⚠️ Aucun token pour récupérer l\'utilisateur');
      return;
    }

    final url = Uri.parse('${Constants.getApiUrl()}${Constants.authMe}');

    print('🌐 Fetching user from: $url');
    print(
      '🔑 Using token: ${_authToken!.substring(0, min(_authToken!.length, 30))}...',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('📡 Réponse get-current-user: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _currentVendor = Vendor(
        id: data['id']?.toString() ?? data['user_id']?.toString() ?? '',
        email: data['email'] ?? '',
        name: data['full_name'] ?? data['name'] ?? '',
        role: data['role'] ?? 'vendeur',
        phone: data['telephone'] ?? data['phone'] ?? '',
        address: data['adresse'] ?? data['address'] ?? '',
        isActive: data['is_active'] ?? true,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : DateTime.now(),
        sellerId: data['seller_id']?.toString(),
        companyName: data['company_name'],
        subscriptionStatus:
            data['abonnement_status'] ??
            data['subscription_status'] ??
            'active',
      );

      // Mettre à jour le stockage
      await _storeUserInfo(data);

      print('✅ Utilisateur récupéré: ${_currentVendor!.email}');
    } else if (response.statusCode == 401) {
      print('⚠️ Token invalide ou expiré');
      await _clearSession();
      throw Exception('Session expirée');
    } else {
      final error = jsonDecode(response.body);
      final errorMsg =
          error['detail'] ??
          error['message'] ??
          'Erreur de récupération du profil';
      throw Exception(errorMsg);
    }
  }

  // ================================
  // MOT DE PASSE OUBLIÉ
  // ================================
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📧 Demande de réinitialisation pour: $email');

      final url = Uri.parse(
        '${Constants.getApiUrl()}${Constants.authForgotPassword}',
      );
      final body = jsonEncode({'email': email});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📡 Réponse forgot-password: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ??
              error['message'] ??
              'Échec de la demande de réinitialisation',
        );
      }
    } catch (e) {
      print('❌ Erreur forgotPassword: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // 🔁 RENVoyer le code de réinitialisation
  // ================================
  Future<void> resendResetCode(String email) async {
    // On utilise la méthode existante forgotPassword
    await forgotPassword(email);
    print('🔄 Code de réinitialisation renvoyé pour $email');
  }

  // ================================
  // VÉRIFICATION CODE DE RÉINITIALISATION
  // ================================
  Future<String> verifyResetCode(String email, String code) async {
    try {
      print('🔍 Vérification du code pour: $email');

      final url = Uri.parse(
        '${Constants.getApiUrl()}${Constants.authVerifyResetCode}',
      );
      final body = jsonEncode({'email': email, 'code': code});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📡 Réponse verify-reset-code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reset_token'] ?? data['token'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? error['message'] ?? 'Code invalide ou expiré',
        );
      }
    } catch (e) {
      print('❌ Erreur verifyResetCode: $e');
      rethrow;
    }
  }

  // ================================
  // RÉINITIALISATION MOT DE PASSE
  // ================================
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String resetToken,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Réinitialisation mot de passe pour: $email');

      final url = Uri.parse(
        '${Constants.getApiUrl()}${Constants.authResetPassword}',
      );
      final body = jsonEncode({
        'email': email,
        'new_password': newPassword,
        'reset_token': resetToken,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📡 Réponse reset-password: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? error['message'] ?? 'Échec de la réinitialisation',
        );
      }
    } catch (e) {
      print('❌ Erreur resetPassword: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // VÉRIFICATION DISPONIBILITÉ EMAIL
  // ================================
  Future<bool> checkEmailAvailability(String email) async {
    try {
      print('📧 Vérification email: $email');

      final url = Uri.parse(
        '${Constants.getApiUrl()}${Constants.authCheckEmail}/$email',
      );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      print('📡 Réponse check-email: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? false;
      } else {
        throw Exception('Impossible de vérifier l\'email');
      }
    } catch (e) {
      print('❌ Erreur checkEmail: $e');
      rethrow;
    }
  }

  // ================================
  // NETTOYAGE DE SESSION
  // ================================
  Future<void> _clearSession() async {
    try {
      // 1. Supprimer Secure Storage
      await _secureStorage.delete(key: 'jwt_token');
      await _secureStorage.delete(key: 'user_data');

      // 2. Supprimer SharedPreferences
      await _initPrefs(); // S'assurer que _prefs est initialisé
      await _prefs?.remove('auth_token');

      // 3. Réinitialiser l'état
      _authToken = null;
      _currentVendor = null;
      _isInitialized = true;

      print('🧹 Session nettoyée (SecureStorage + SharedPreferences)');
    } catch (e) {
      print('❌ Erreur nettoyage session: $e');
    } finally {
      notifyListeners();
    }
  }

  // ================================
  // UTILITAIRES
  // ================================
  Future<String?> getToken() async {
    try {
      await _initPrefs(); // S'assurer que _prefs est initialisé

      // Essayer d'abord Secure Storage
      var token = await _secureStorage.read(key: 'jwt_token');

      // Fallback vers SharedPreferences
      if (token == null || token.isEmpty) {
        token = _prefs?.getString('auth_token');
      }

      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération user data: $e');
      return null;
    }
  }

  /// Met à jour les informations du vendeur localement
  void updateCurrentVendor({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? companyName,
  }) {
    if (_currentVendor != null) {
      _currentVendor = _currentVendor!.copyWith(
        name: name ?? _currentVendor!.name,
        email: email ?? _currentVendor!.email,
        phone: phone ?? _currentVendor!.phone,
        address: address ?? _currentVendor!.address,
        companyName: companyName ?? _currentVendor!.companyName,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Retourne la route de redirection selon le rôle
  String getRedirectRoute() {
    if (!isAuthenticated) return '/login';

    if (isVendor) return '/dashboard';
    if (isDelivery) return '/delivery-dashboard';
    if (isAdmin) return '/admin-dashboard';

    return '/login';
  }

  /// Vérifie si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    return _currentVendor?.role.toLowerCase() == role.toLowerCase();
  }

  /// Rafraîchir le token (pour prolonger la session)
  Future<void> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        throw Exception('Aucun token à rafraîchir');
      }

      // Appeler votre endpoint de rafraîchissement si disponible
      // Sinon, juste refetch l'utilisateur
      await _fetchCurrentUser();
      print('🔄 Token rafraîchi');
    } catch (e) {
      print('❌ Erreur rafraîchissement token: $e');
      await _clearSession();
    }
  }
}

// Factory pour créer le service
Future<AuthService> createAuthService() async {
  final service = AuthService();
  await service.initializeSession();
  return service;
}

// Helper pour l'injection de dépendances
class AuthProvider {
  static late AuthService _instance;

  static Future<void> initialize() async {
    _instance = await createAuthService();
  }

  static AuthService get instance => _instance;
}
