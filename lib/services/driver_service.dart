// lib/services/driver_service.dart
import 'dart:convert';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';

class DriverService with ChangeNotifier {
  List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statsSummary;
  List<String>? _availableZones;
  String? _authToken;
  SharedPreferences? _prefs; // Ajout de SharedPreferences

  DriverService();

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get statsSummary => _statsSummary;
  List<String>? get availableZones => _availableZones;

  // =========================================
  // INITIALISATION ET GESTION DU TOKEN
  // =========================================

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initializeToken() async {
    try {
      await _initPrefs();

      // Récupérer le token depuis SharedPreferences
      _authToken = _prefs?.getString('auth_token');

      if (_authToken != null && _authToken!.isNotEmpty) {
        if (kDebugMode) {
          print(
            '✅ Token récupéré dans DriverService: ${_authToken!.substring(0, min(_authToken!.length, 30))}...',
          );
        }
      } else {
        // Essayer aussi depuis Secure Storage (via une clé directe)
        final storage = const FlutterSecureStorage();
        _authToken = await storage.read(key: 'jwt_token');

        if (_authToken != null && _authToken!.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Token récupéré depuis SecureStorage dans DriverService');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Aucun token trouvé pour DriverService');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation token DriverService: $e');
      }
    }
  }

  void setAuthToken(String token) {
    _authToken = token;
    if (kDebugMode) {
      print('🔑 Token défini manuellement dans DriverService');
    }
  }

  void clearAuthToken() {
    _authToken = null;
    if (kDebugMode) {
      print('🧹 Token effacé dans DriverService');
    }
  }

  // =========================================
  // GESTION D'ÉTAT
  // =========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearDrivers() {
    _drivers.clear();
    notifyListeners();
  }

  // =========================================
  // CONFIGURATION API
  // =========================================

  String _getBaseUrl() {
    return Constants.getApiUrl();
  }

  Map<String, String> _getHeaders() {
    // Vérifier et initialiser le token si nécessaire
    if (_authToken == null || _authToken!.isEmpty) {
      // Essayer de récupérer depuis SharedPreferences
      final token = _prefs?.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _authToken = token;
      }
    }

    return Constants.getDefaultHeaders(_authToken);
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String operation,
  ) async {
    try {
      if (kDebugMode) {
        print('[$operation] Status: ${response.statusCode}');
        if (response.body.length < 500) {
          // Éviter d'afficher des réponses trop longues
          print('[$operation] Body: ${response.body}');
        }
      }

      // Vérifier si la réponse est vide
      if (response.body.isEmpty) {
        switch (response.statusCode) {
          case Constants.httpSuccess:
          case Constants.httpNoContent:
            return {
              'success': true,
              'data': {},
              'message': 'Opération réussie',
            };
          default:
            return {'success': false, 'error': 'Réponse vide du serveur'};
        }
      }

      final responseBody = jsonDecode(response.body);

      // Gestion spécifique des erreurs d'authentification
      if (response.statusCode == Constants.httpUnauthorized) {
        // Token expiré ou invalide
        if (kDebugMode) {
          print('🔐 Token invalide ou expiré, déconnexion nécessaire');
        }
        return {
          'success': false,
          'error': 'Session expirée. Veuillez vous reconnecter.',
          'requiresLogin': true,
        };
      }

      switch (response.statusCode) {
        case Constants.httpSuccess:
        case Constants.httpCreated:
        case Constants.httpNoContent:
          return {
            'success': true,
            'data': responseBody,
            'message': responseBody['message'] ?? 'Opération réussie',
          };

        case Constants.httpBadRequest:
          return {
            'success': false,
            'error': responseBody['error'] ?? Constants.errorValidation,
            'details': responseBody['details'],
          };

        case Constants.httpForbidden:
          return {
            'success': false,
            'error':
                responseBody['error'] ??
                'Accès refusé. Permissions insuffisantes.',
          };

        case Constants.httpNotFound:
          return {'success': false, 'error': Constants.errorDriverNotFound};

        case Constants.httpMethodNotAllowed:
          return {'success': false, 'error': Constants.errorMethodNotAllowed};

        case Constants.httpInternalServerError:
          return {'success': false, 'error': Constants.errorServer};

        default:
          return {
            'success': false,
            'error':
                responseBody['error'] ??
                'Erreur inconnue (${response.statusCode})',
          };
      }
    } catch (e) {
      if (kDebugMode) {
        print('[$operation] Parse error: $e');
      }
      return {
        'success': false,
        'error': 'Erreur lors du traitement de la réponse du serveur',
      };
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Vérifier l'initialisation du token
      if (_authToken == null) {
        await initializeToken();
      }

      // Construire l'URL
      String fullUrl = url;
      if (queryParams != null && queryParams.isNotEmpty) {
        fullUrl = Constants.buildUrlWithParams(url, queryParams);
      }

      if (kDebugMode) {
        print('[$method] URL: $fullUrl');
        if (body != null) {
          print('[$method] Body: $body');
        }
      }

      final headers = _getHeaders();

      // Vérifier le token
      final token = headers['Authorization'];
      if (token == null || token.isEmpty || token == 'Bearer null') {
        if (kDebugMode) {
          print('⚠️ Avertissement: Pas de token d\'authentification valide');
        }
        return {
          'success': false,
          'error': 'Non authentifié. Veuillez vous reconnecter.',
          'requiresLogin': true,
        };
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(fullUrl), headers: headers);
          break;

        case 'POST':
          response = await http.post(
            Uri.parse(fullUrl),
            headers: {...headers, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;

        case 'PUT':
          response = await http.put(
            Uri.parse(fullUrl),
            headers: {...headers, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;

        case 'PATCH':
          response = await http.patch(
            Uri.parse(fullUrl),
            headers: {...headers, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          break;

        case 'DELETE':
          response = await http.delete(Uri.parse(fullUrl), headers: headers);
          break;

        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      final result = await _handleResponse(response, method);

      // Gérer les erreurs d'authentification
      if (result['requiresLogin'] == true) {
        clearAuthToken();
        if (_prefs != null) {
          await _prefs!.remove('auth_token');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('[DriverService] Request error: $e');
      }

      // Gestion des erreurs de réseau
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error': 'Erreur de connexion. Vérifiez votre réseau.',
          'networkError': true,
        };
      }

      return {'success': false, 'error': 'Erreur: ${e.toString()}'};
    } finally {
      _setLoading(false);
    }
  }

  // =========================================
  // MÉTHODES PRINCIPALES POUR LES LIVREURS
  // =========================================

  /// 1. Tester les permissions
  Future<Map<String, dynamic>> testPermissions() async {
    final url = '${_getBaseUrl()}${Constants.driversTest}';
    return await _makeRequest('GET', url, null);
  }

  /// 2. Créer un nouveau livreur avec envoi d'email
  Future<Map<String, dynamic>> createDriverWithEmail(
    Map<String, dynamic> driverData,
  ) async {
    // Validation
    final errors = validateDriverData(driverData);
    if (errors.isNotEmpty) {
      return {
        'success': false,
        'error': errors.join(', '),
        'validationErrors': errors,
      };
    }

    // Préparer les données
    final apiData = {
      'full_name': driverData['full_name'],
      'email': driverData['email'],
      'telephone': driverData['telephone'],
      'adresse': driverData['adresse'],
      'password': driverData['password'],
      'statut': driverData['statut'] ?? 'en_attente',
      if (driverData.containsKey('zone_livraison') &&
          driverData['zone_livraison'] != null &&
          driverData['zone_livraison'].toString().isNotEmpty)
        'zone_livraison': driverData['zone_livraison'],
    };

    final url = '${_getBaseUrl()}${Constants.driversCreate}';
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

    _setError(result['error']);
    return result;
  }

  /// 3. Récupérer la liste des livreurs (CORRIGÉ)
  Future<DriversResponse> getDrivers({
    int page = 1,
    int pageSize = Constants.defaultPageSize,
    String? status,
    String? search,
    String? zone,
    bool? disponibilite,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (status != null && status.isNotEmpty) 'statut': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (zone != null && zone.isNotEmpty) 'zone': zone,
      if (disponibilite != null) 'disponibilite': disponibilite.toString(),
    };

    final url = '${_getBaseUrl()}${Constants.driversList}';
    final result = await _makeRequest(
      'GET',
      url,
      null,
      queryParams: queryParams,
    );

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      // CORRECTION: Gérer différentes clés possibles
      final List<dynamic> driversList =
          data['drivers'] ?? data['data'] ?? data['results'] ?? [];

      // Convertir en objets Driver
      final drivers = driversList.map((driverData) {
        return Driver(
          id:
              driverData['driver_id']?.toString() ??
              driverData['id']?.toString() ??
              '',
          user_id: driverData['user_id']?.toString() ?? '',
          seller_id: driverData['seller_id']?.toString() ?? '',
          zone_livraison: driverData['zone_livraison']?.toString() ?? '',
          disponibilite: driverData['disponibilite'] ?? false,
          created_at:
              DateTime.tryParse(driverData['created_at']?.toString() ?? '') ??
              DateTime.now(),
          updated_at:
              DateTime.tryParse(driverData['updated_at']?.toString() ?? '') ??
              DateTime.now(),
          user: User(
            id: driverData['user_id']?.toString() ?? '',
            full_name: driverData['full_name']?.toString() ?? '',
            email: driverData['email']?.toString() ?? '',
            telephone: driverData['telephone']?.toString() ?? '',
            adresse: driverData['adresse']?.toString() ?? '',
            role: driverData['role']?.toString() ?? 'LIVREUR',
            statut: driverData['statut']?.toString() ?? 'en_attente',
            is_active: driverData['is_active'] ?? false,
          ),
        );
      }).toList();

      // Mettre à jour la liste
      if (page == 1) {
        _drivers = drivers;
      } else {
        _drivers.addAll(drivers);
      }

      notifyListeners();

      // Créer la réponse
      return DriversResponse(
        count: (data['count'] ?? drivers.length).toInt(),
        total: (data['total'] ?? drivers.length).toInt(),
        active: (data['active'] ?? 0).toInt(),
        available: (data['available'] ?? 0).toInt(),
        seller: data['seller'] != null
            ? Map<String, String>.from(data['seller'])
            : {'id': '', 'name': '', 'email': ''},
        drivers: drivers,
      );
    }

    _setError(result['error']);
    return DriversResponse(
      count: 0,
      total: 0,
      active: 0,
      available: 0,
      seller: {'id': '', 'name': '', 'email': ''},
      drivers: [],
    );
  }

  /// 4. Récupérer les détails d'un livreur
  Future<Driver?> getDriver(String driverId) async {
    final url = '${_getBaseUrl()}${Constants.driversDetail(driverId)}';
    final result = await _makeRequest('GET', url, null);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return Driver(
        id: data['driver_id']?.toString() ?? data['id']?.toString() ?? driverId,
        user_id: data['user_id']?.toString() ?? '',
        seller_id: data['seller_id']?.toString() ?? '',
        zone_livraison: data['zone_livraison']?.toString() ?? '',
        disponibilite: data['disponibilite'] ?? false,
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
    }

    _setError(result['error']);
    return null;
  }

  /// 5. Mettre à jour un livreur
  Future<Map<String, dynamic>> updateDriver(
    String driverId,
    Map<String, dynamic> updateData,
  ) async {
    // Nettoyer les données nulles
    final cleanData = Map<String, dynamic>.from(updateData)
      ..removeWhere((key, value) => value == null || value.toString().isEmpty);

    if (cleanData.isEmpty) {
      return {'success': false, 'error': 'Aucune donnée à mettre à jour'};
    }

    final url = '${_getBaseUrl()}${Constants.driversUpdate(driverId)}';
    final result = await _makeRequest('PUT', url, cleanData);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      // Mettre à jour localement
      final index = _drivers.indexWhere((driver) => driver.id == driverId);
      if (index != -1) {
        final oldDriver = _drivers[index];
        final updatedDriver = oldDriver.copyWith(
          zone_livraison:
              data['zone_livraison']?.toString() ?? oldDriver.zone_livraison,
          disponibilite: data['disponibilite'] ?? oldDriver.disponibilite,
          updated_at: DateTime.now(),
          user: oldDriver.user.copyWith(
            full_name:
                data['full_name']?.toString() ?? oldDriver.user.full_name,
            telephone:
                data['telephone']?.toString() ?? oldDriver.user.telephone,
            adresse: data['adresse']?.toString() ?? oldDriver.user.adresse,
            statut: data['statut']?.toString() ?? oldDriver.user.statut,
            is_active: data['is_active'] ?? oldDriver.user.is_active,
          ),
        );
        _drivers[index] = updatedDriver;
        notifyListeners();
      }

      return {
        'success': true,
        'data': data,
        'message': 'Livreur mis à jour avec succès',
      };
    }

    _setError(result['error']);
    return result;
  }

  /// 6. Activer un livreur
  Future<Map<String, dynamic>> activateDriver(String driverId) async {
    final url = '${_getBaseUrl()}${Constants.driversActivate(driverId)}';
    final result = await _makeRequest('PATCH', url, {'statut': 'actif'});

    if (result['success'] == true) {
      // Mettre à jour localement
      final index = _drivers.indexWhere((driver) => driver.id == driverId);
      if (index != -1) {
        final oldDriver = _drivers[index];
        final updatedDriver = oldDriver.copyWith(
          disponibilite: true,
          updated_at: DateTime.now(),
          user: oldDriver.user.copyWith(statut: 'actif', is_active: true),
        );
        _drivers[index] = updatedDriver;
        notifyListeners();
      }

      return {
        'success': true,
        'message': 'Livreur activé avec succès',
        'data': result['data'],
      };
    }

    _setError(result['error']);
    return result;
  }

  /// 7. Suspendre un livreur
  Future<Map<String, dynamic>> suspendDriver(String driverId) async {
    final url = '${_getBaseUrl()}${Constants.driversSuspend(driverId)}';
    final result = await _makeRequest('PATCH', url, {'statut': 'suspendu'});

    if (result['success'] == true) {
      // Mettre à jour localement
      final index = _drivers.indexWhere((driver) => driver.id == driverId);
      if (index != -1) {
        final oldDriver = _drivers[index];
        final updatedDriver = oldDriver.copyWith(
          disponibilite: false,
          updated_at: DateTime.now(),
          user: oldDriver.user.copyWith(statut: 'suspendu', is_active: false),
        );
        _drivers[index] = updatedDriver;
        notifyListeners();
      }

      return {
        'success': true,
        'message': 'Livreur suspendu avec succès',
        'data': result['data'],
      };
    }

    _setError(result['error']);
    return result;
  }

  /// 8. Supprimer un livreur (CORRIGÉ)
  Future<Map<String, dynamic>> deleteDriver(String driverId) async {
    try {
      final url = '${_getBaseUrl()}${Constants.driversDelete(driverId)}';
      final result = await _makeRequest('DELETE', url, null);

      if (result['success'] == true) {
        // OPTION 1: Marquer comme supprimé localement (soft delete)
        final index = _drivers.indexWhere((driver) => driver.id == driverId);
        if (index != -1) {
          final oldDriver = _drivers[index];
          final updatedDriver = oldDriver.copyWith(
            is_deleted: true,
            deleted_at: DateTime.now(),
            updated_at: DateTime.now(),
          );
          _drivers[index] = updatedDriver;
          notifyListeners();
        }

        // OPTION 2: Supprimer complètement de la liste locale
        // _drivers.removeWhere((driver) => driver.id == driverId);
        // notifyListeners();

        return {
          'success': true,
          'message': 'Livreur supprimé avec succès',
          'data': result['data'],
        };
      }

      _setError(result['error']);
      return result;
    } catch (e) {
      return {'success': false, 'error': 'Erreur lors de la suppression: $e'};
    }
  }

  /// 9. Récupérer les statistiques
  Future<Map<String, dynamic>> getStatsSummary() async {
    final url = '${_getBaseUrl()}${Constants.driversStatsSummary}';
    final result = await _makeRequest('GET', url, null);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      _statsSummary = data;
      notifyListeners();

      return {
        'success': true,
        'data': data,
        'stats': data['stats'] ?? {},
        'seller': data['seller'] ?? {},
      };
    }

    _setError(result['error']);
    return result;
  }

  /// 10. Récupérer les zones disponibles
  Future<Map<String, dynamic>> getAvailableZones() async {
    final url = '${_getBaseUrl()}${Constants.driversZonesAvailable}';
    final result = await _makeRequest('GET', url, null);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      _availableZones = List<String>.from(data['zones'] ?? []);
      notifyListeners();

      return {'success': true, 'data': data, 'zones': data['zones'] ?? []};
    }

    _setError(result['error']);
    // Zones par défaut en cas d'erreur
    return {
      'success': false,
      'error': result['error'],
      'zones': Constants.commonZonesMadagascar,
    };
  }

  /// 11. Mettre à jour la géolocalisation
  Future<Map<String, dynamic>> updateGeolocation(String driverId) async {
    final url =
        '${_getBaseUrl()}${Constants.driversUpdateGeolocation(driverId)}';
    final result = await _makeRequest('POST', url, null);

    if (result['success'] == true) {
      // Mettre à jour localement
      final index = _drivers.indexWhere((driver) => driver.id == driverId);
      if (index != -1 && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final oldDriver = _drivers[index];
        final updatedDriver = oldDriver.copyWith(
          zone_livraison:
              data['new_zone']?.toString() ?? oldDriver.zone_livraison,
          updated_at: DateTime.now(),
        );
        _drivers[index] = updatedDriver;
        notifyListeners();
      }

      return {
        'success': true,
        'message': 'Géolocalisation mise à jour',
        'data': result['data'],
      };
    }

    _setError(result['error']);
    return result;
  }

  /// 12. Mettre à jour la disponibilité
  Future<Map<String, dynamic>> updateDriverAvailability(
    String driverId,
    bool available,
  ) async {
    return await updateDriver(driverId, {'disponibilite': available});
  }

  // =========================================
  // MÉTHODES UTILITAIRES AMÉLIORÉES
  // =========================================

  Future<String?> detectZoneFromAddress(String address) async {
    try {
      if (address.isEmpty) return null;

      final lowerAddress = address.toLowerCase();

      // Vérifier les codes postaux
      for (final entry in Constants.postalCodeToZone.entries) {
        if (lowerAddress.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }

      // Vérifier les zones
      for (final zone in Constants.commonZonesMadagascar) {
        if (lowerAddress.contains(zone.toLowerCase())) {
          return zone;
        }
      }

      // Détection par ville
      if (lowerAddress.contains('tana') || lowerAddress.contains('antan')) {
        return 'Antananarivo Centre';
      } else if (lowerAddress.contains('toamasina') ||
          lowerAddress.contains('tamatave')) {
        return 'Toamasina I';
      } else if (lowerAddress.contains('mahajanga') ||
          lowerAddress.contains('majunga')) {
        return 'Mahajanga I';
      }

      return 'Antananarivo Centre'; // Zone par défaut
    } catch (e) {
      if (kDebugMode) {
        print('Zone detection error: $e');
      }
      return null;
    }
  }

  List<Driver> filterDriversByStatus(String status) {
    return _drivers.where((driver) => driver.statut == status).toList();
  }

  List<Driver> searchDrivers(String query) {
    if (query.isEmpty) return _drivers;

    final lowerQuery = query.toLowerCase();
    return _drivers.where((driver) {
      return driver.fullName.toLowerCase().contains(lowerQuery) ||
          driver.email.toLowerCase().contains(lowerQuery) ||
          driver.telephone.contains(query) ||
          driver.adresse.toLowerCase().contains(lowerQuery) ||
          driver.zone_livraison.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Driver? getDriverById(String driverId) {
    try {
      return _drivers.firstWhere((driver) => driver.id == driverId);
    } catch (e) {
      return null;
    }
  }

  bool isEmailAvailable(String email) {
    return !_drivers.any((driver) => driver.email == email);
  }

  Future<void> refreshDrivers() async {
    await getDrivers(page: 1);
  }

  int getDriverCountByStatus(String status) {
    return _drivers.where((driver) => driver.statut == status).length;
  }

  int getAvailableDriversCount() {
    return _drivers.where((driver) => driver.disponibilite).length;
  }

  Map<String, List<Driver>> getDriversByZone() {
    final Map<String, List<Driver>> driversByZone = {};

    for (final driver in _drivers) {
      final zone = driver.zone_livraison;
      if (!driversByZone.containsKey(zone)) {
        driversByZone[zone] = [];
      }
      driversByZone[zone]!.add(driver);
    }

    return driversByZone;
  }

  Map<String, int> getBasicStats() {
    return {
      'total': _drivers.length,
      'actifs': getDriverCountByStatus('actif'),
      'en_attente': getDriverCountByStatus('en_attente'),
      'suspendus': getDriverCountByStatus('suspendu'),
      'rejetés': getDriverCountByStatus('rejeté'),
      'disponibles': getAvailableDriversCount(),
    };
  }

  Map<String, dynamic> formatDriverDataForCreation({
    required String fullName,
    required String email,
    required String telephone,
    required String address,
    required String password,
    String? zone,
    String status = 'en_attente',
  }) {
    return {
      'full_name': fullName,
      'email': email,
      'telephone': telephone,
      'adresse': address,
      'password': password,
      'statut': status,
      if (zone != null && zone.isNotEmpty) 'zone_livraison': zone,
    };
  }

  List<String> validateDriverData(Map<String, dynamic> data) {
    final errors = <String>[];

    if (data['full_name']?.toString().isEmpty ?? true) {
      errors.add('Le nom complet est requis');
    }

    if (data['email']?.toString().isEmpty ?? true) {
      errors.add('L\'email est requis');
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(data['email'].toString())) {
        errors.add('Format d\'email invalide');
      }
    }

    if (data['telephone']?.toString().isEmpty ?? true) {
      errors.add('Le téléphone est requis');
    }

    if (data['adresse']?.toString().isEmpty ?? true) {
      errors.add('L\'adresse est requise');
    }

    if (data['password']?.toString().isEmpty ?? true) {
      errors.add('Le mot de passe est requis');
    } else if (data['password'].toString().length < 6) {
      errors.add('Le mot de passe doit avoir au moins 6 caractères');
    }

    return errors;
  }

  // Nouvelle méthode pour initialiser le service
  Future<void> initialize() async {
    await initializeToken();
    await getStatsSummary();
    await getAvailableZones();
  }
}

// Factory function pour créer le service
Future<DriverService> createDriverService() async {
  final service = DriverService();
  await service.initialize();
  return service;
}

// Helper pour min
int min(int a, int b) => a < b ? a : b;
