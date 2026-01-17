// lib/services/driver_service.dart - VERSION CORRIGÉE
import 'dart:convert';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';

class DriverService with ChangeNotifier {
  List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _error;
  SharedPreferences? _prefs;

  DriverService();

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =========================================
  // INITIALISATION
  // =========================================

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> _getAuthToken() async {
    await _initPrefs();
    return _prefs?.getString('auth_token');
  }

  // =========================================
  // HEADERS POUR NGROK
  // =========================================

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
      'Origin': 'http://localhost',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Vérifie si la réponse est du HTML (page ngrok)
  bool _isHtmlResponse(String body) {
    final trimmed = body.trim();
    return trimmed.startsWith('<!DOCTYPE') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('ngrok.com') ||
        trimmed.contains('You are about to visit');
  }

  // =========================================
  // MÉTHODE DE REQUÊTE SIMPLIFIÉE
  // =========================================

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Construire l'URL avec query params
      String fullUrl = url;
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(
          queryParameters: queryParams.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
        fullUrl = uri.toString();
      }

      final headers = await _getHeaders();

      if (kDebugMode) {
        print('[DriverService] $method: $fullUrl');
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(Uri.parse(fullUrl), headers: headers)
              .timeout(const Duration(seconds: 15));
          break;

        case 'POST':
          response = await http
              .post(
                Uri.parse(fullUrl),
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 15));
          break;

        case 'PUT':
          response = await http
              .put(
                Uri.parse(fullUrl),
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 15));
          break;

        case 'DELETE':
          response = await http
              .delete(Uri.parse(fullUrl), headers: headers)
              .timeout(const Duration(seconds: 15));
          break;

        default:
          throw Exception('Méthode non supportée: $method');
      }

      if (kDebugMode) {
        print('[DriverService] Status: ${response.statusCode}');
      }

      // Vérifier si c'est du HTML (ngrok bloque)
      if (_isHtmlResponse(response.body)) {
        throw Exception('Serveur temporairement indisponible (ngrok)');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 403) {
        throw Exception('Non authentifié. Token manquant ou invalide.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DriverService] Erreur: $e');
      }
      _error = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================
  // MÉTHODES PRINCIPALES
  // =========================================

  /// Récupérer la liste des livreurs
  Future<DriversResponse> getDrivers({
    int page = 1,
    int pageSize = 10,
    String? status,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (status != null && status.isNotEmpty) 'statut': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final url = '${Constants.apiBaseUrl}/api/v1/drivers/';

    final result = await _makeRequest(
      'GET',
      url,
      null,
      queryParams: queryParams,
    );

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      // Parser les drivers
      final driversList = data['drivers'] as List;
      final drivers = driversList.map((driverData) {
        return Driver.fromJson(driverData);
      }).toList();

      // Mettre à jour la liste
      _drivers = drivers;
      notifyListeners();

      return DriversResponse(
        count: data['count'] ?? 0,
        total: data['total'] ?? 0,
        active: data['active'] ?? 0,
        available: data['available'] ?? 0,
        seller: data['seller'] ?? {},
        drivers: drivers,
      );
    }

    return DriversResponse(
      count: 0,
      total: 0,
      active: 0,
      available: 0,
      seller: {},
      drivers: [],
    );
  }

  /// Créer un livreur
  Future<Map<String, dynamic>> createDriver(Map<String, dynamic> data) async {
    final url = '${Constants.apiBaseUrl}/api/v1/drivers/';
    return await _makeRequest('POST', url, data);
  }

  /// Mettre à jour un livreur
  Future<Map<String, dynamic>> updateDriver(
    String driverId,
    Map<String, dynamic> data,
  ) async {
    final url = '${Constants.apiBaseUrl}/api/v1/drivers/$driverId/';
    return await _makeRequest('PUT', url, data);
  }

  /// Supprimer un livreur
  Future<Map<String, dynamic>> deleteDriver(String driverId) async {
    final url = '${Constants.apiBaseUrl}/api/v1/drivers/$driverId/';
    return await _makeRequest('DELETE', url, null);
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await getDrivers();
  }

  /// Rechercher localement
  List<Driver> searchLocalDrivers(String query) {
    if (query.isEmpty) return _drivers;

    final lowerQuery = query.toLowerCase();
    return _drivers.where((driver) {
      return driver.fullName.toLowerCase().contains(lowerQuery) ||
          driver.email.toLowerCase().contains(lowerQuery) ||
          driver.telephone.contains(query);
    }).toList();
  }

  /// Filtrer par statut
  List<Driver> filterByStatus(String? status) {
    if (status == null) return _drivers;
    return _drivers.where((driver) => driver.statut == status).toList();
  }

  /// Obtenir les statistiques
  Map<String, int> getStats() {
    return {
      'total': _drivers.length,
      'actifs': _drivers.where((d) => d.statut == 'actif').length,
      'en_attente': _drivers.where((d) => d.statut == 'en_attente').length,
      'suspendus': _drivers.where((d) => d.statut == 'suspendu').length,
      'rejetés': _drivers.where((d) => d.statut == 'rejeté').length,
      'disponibles': _drivers.where((d) => d.disponibilite).length,
    };
  }

  // Ajoute cette méthode dans la classe DriverService (à la fin mais à l'intérieur de la classe)
  Future<Map<String, dynamic>> createDriverWithEmail(
    Map<String, dynamic> driverData,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validation simple
      final errors = <String>[];
      if (driverData['full_name']?.toString().isEmpty ?? true) {
        errors.add('Le nom complet est requis');
      }
      if (driverData['email']?.toString().isEmpty ?? true) {
        errors.add('L\'email est requis');
      }
      if (driverData['telephone']?.toString().isEmpty ?? true) {
        errors.add('Le téléphone est requis');
      }
      if (driverData['password']?.toString().isEmpty ?? true) {
        errors.add('Le mot de passe est requis');
      }

      if (errors.isNotEmpty) {
        return {
          'success': false,
          'error': errors.join(', '),
          'validationErrors': errors,
        };
      }

      // Préparer les données pour l'API
      final apiData = {
        'full_name': driverData['full_name'].toString().trim(),
        'email': driverData['email'].toString().trim(),
        'telephone': driverData['telephone'].toString().trim(),
        'adresse': driverData['adresse']?.toString().trim() ?? '',
        'password': driverData['password'].toString(),
        'statut': driverData['statut'] ?? 'en_attente',
      };

      // Ajouter zone de livraison si fournie
      if (driverData['zone_livraison'] != null &&
          driverData['zone_livraison'].toString().isNotEmpty) {
        apiData['zone_livraison'] = driverData['zone_livraison'].toString();
      }

      // CORRECTION ICI : utiliser apiBaseUrl au lieu de baseUrl
      final url = '${Constants.apiBaseUrl}/api/v1/drivers/';
      final result = await _makeRequest('POST', url, apiData);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;

        // Créer l'objet Driver
        final driver = Driver(
          id: data['driver_id']?.toString() ?? data['id']?.toString() ?? '',
          user_id: data['user_id']?.toString() ?? '',
          seller_id: data['seller_id']?.toString() ?? '',
          zone_livraison: data['zone_livraison']?.toString() ?? '',
          disponibilite: data['disponibilite'] ?? true,
          created_at:
              DateTime.tryParse(data['created_at']?.toString() ?? '') ??
              DateTime.now(),
          updated_at:
              DateTime.tryParse(data['updated_at']?.toString() ?? '') ??
              DateTime.now(),
          user: User(
            id: data['user_id']?.toString() ?? '',
            full_name: data['full_name']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
            telephone: data['telephone']?.toString() ?? '',
            adresse: data['adresse']?.toString() ?? '',
            role: data['role']?.toString() ?? 'LIVREUR',
            statut: data['statut']?.toString() ?? 'en_attente',
            is_active: data['is_active'] ?? false,
          ),
        );

        // Ajouter à la liste locale
        _drivers.add(driver);
        notifyListeners();

        return {
          'success': true,
          'data': data,
          'driver': driver,
          'message': 'Livreur créé avec succès. Un email a été envoyé.',
        };
      }

      _error = result['error']?.toString();
      return result;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
