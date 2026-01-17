// lib/services/facebook_service.dart - VERSION COMPLÈTE CORRIGÉE
// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:commerce/models/facebook_models.dart';
import 'package:commerce/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacebookService {
  final AuthService _authService;
  late SharedPreferences _prefs;

  final Map<String, dynamic> _cache = {};
  DateTime? _lastCacheUpdate;

  FacebookService(this._authService) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== GESTION DU TOKEN ====================

  Future<String?> _getAuthToken() async {
    // 1. Essayer depuis AuthService
    final authServiceToken = _authService.authToken;
    if (authServiceToken != null && authServiceToken.isNotEmpty) {
      return authServiceToken;
    }

    // 2. Essayer depuis SharedPreferences
    await _initPrefs();
    final prefsToken = _prefs.getString('auth_token');
    if (prefsToken != null && prefsToken.isNotEmpty) {
      return prefsToken;
    }

    return null;
  }

  // ==================== HEADERS ====================

  Map<String, String> _getBasicHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
      'Origin': 'http://localhost',
    };
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    final headers = _getBasicHeaders();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================== GESTION DES RÉPONSES ====================

  Map<String, dynamic> _parseErrorResponse(
    http.Response response,
    String defaultError,
  ) {
    try {
      if (response.body.isNotEmpty) {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final Map<String, dynamic> errorMap = {};
          decoded.forEach((key, value) {
            if (key is String) {
              errorMap[key] = value;
            } else if (key != null) {
              errorMap[key.toString()] = value;
            }
          });

          final error =
              errorMap['error']?.toString() ??
              errorMap['detail']?.toString() ??
              errorMap['message']?.toString() ??
              defaultError;

          return {
            'success': false,
            'error': error,
            'status_code': response.statusCode,
          };
        }
      }
    } catch (_) {
      // Ignorer les erreurs de parsing
    }

    return {
      'success': false,
      'error': defaultError,
      'status_code': response.statusCode,
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final path = response.request?.url.path ?? 'unknown';
    debugPrint('Facebook API: ${response.statusCode} $path');

    // Vérifier si c'est une réponse HTML
    final bodyStr = response.body.trim();
    if (bodyStr.startsWith('<!DOCTYPE') || bodyStr.startsWith('<html')) {
      throw Exception('Serveur temporairement indisponible');
    }

    // Gérer les codes de statut
    switch (response.statusCode) {
      case 200:
      case 201:
        return _parseSuccessResponse(response);
      case 204:
        return {'success': true, 'message': 'Operation successful'};
      case 400:
        return _parseErrorResponse(response, 'Requête invalide');
      case 401:
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      case 403:
        throw Exception(
          'Accès refusé. Vous n\'avez pas les permissions nécessaires.',
        );
      case 404:
        // Pour les pages Facebook, retourner une liste vide si 404
        if (path.contains('/facebook/pages')) {
          return {'success': true, 'pages': []};
        }
        return {'success': false, 'error': 'Resource not found'};
      case 500:
        throw Exception(
          'Erreur serveur interne. Veuillez réessayer plus tard.',
        );
      default:
        throw Exception('Erreur inconnue: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _parseSuccessResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return {'success': true, 'message': 'Operation successful'};
      }

      final decoded = json.decode(response.body);

      if (decoded == null) {
        return {'success': true, 'message': 'Operation successful'};
      }

      if (decoded is Map<String, dynamic>) {
        return {'success': true, ...decoded};
      } else if (decoded is Map) {
        final Map<String, dynamic> convertedMap = {};
        decoded.forEach((key, value) {
          if (key is String) {
            convertedMap[key] = value;
          } else if (key != null) {
            convertedMap[key.toString()] = value;
          }
        });
        return {'success': true, ...convertedMap};
      } else {
        return {'success': true, 'data': decoded};
      }
    } catch (e) {
      debugPrint('JSON decode error: $e - Body: ${response.body}');
      return {'success': true, 'message': 'Operation successful'};
    }
  }

  // ==================== CONNEXION FACEBOOK ====================

  Future<FacebookConnectResponse> connectToFacebook() async {
    try {
      // CORRECTION ICI : Utiliser Constants.apiBaseUrl + Constants.facebookLogin
      final url = Uri.parse(Constants.apiBaseUrl + Constants.facebookLogin);
      final headers = await _getHeaders();

      debugPrint('🌐 Facebook Connect URL: $url');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 404) {
        // Si l'endpoint n'existe pas, retourner une URL d'authentification Facebook
        debugPrint('⚠️ Endpoint Facebook non trouvé, utilisant URL par défaut');

        // URL OAuth Facebook par défaut (à adapter avec tes credentials)
        final facebookAppId = '1108236994559018'; // À remplacer
        final redirectUri = '${Constants.apiBaseUrl}/facebook/callback';
        final permissions =
            'pages_show_list,pages_manage_posts,pages_messaging';

        final authUrl =
            'https://www.facebook.com/v17.0/dialog/oauth?'
            'client_id=$facebookAppId&'
            'redirect_uri=$redirectUri&'
            'scope=$permissions&'
            'response_type=code&'
            'state=${DateTime.now().millisecondsSinceEpoch}';

        return FacebookConnectResponse(success: true, authUrl: authUrl);
      }

      final data = await _handleResponse(response);

      final bool success = data.containsKey('success')
          ? (data['success'] ?? false)
          : false;

      final String authUrl = data.containsKey('auth_url')
          ? (data['auth_url']?.toString() ?? '')
          : '';

      return FacebookConnectResponse(success: success, authUrl: authUrl);
    } catch (e) {
      debugPrint('❌ Facebook connection error: $e');
      return FacebookConnectResponse(success: false, authUrl: '');
    }
  }

  Future<bool> disconnectFacebook() async {
    try {
      // CORRECTION ICI : Utiliser Constants.apiBaseUrl + Constants.facebookDisconnect
      final url = Uri.parse(
        Constants.apiBaseUrl + Constants.facebookDisconnect,
      );
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      final data = await _handleResponse(response);

      // Vider le cache après déconnexion
      _clearCache();

      return (data['success'] ?? false);
    } catch (e) {
      debugPrint('❌ Facebook disconnect error: $e');
      return false;
    }
  }

  // ==================== GESTION DES PAGES ====================

  Future<List<FacebookPage>> getFacebookPages({
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'facebook_pages';

    // Vérifier le cache
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (cached is List<FacebookPage>) {
        debugPrint('📦 Using cached Facebook pages');
        return cached;
      }
    }

    try {
      // CORRECTION ICI : Utiliser Constants.apiBaseUrl + Constants.facebookPages
      final url = Uri.parse(Constants.apiBaseUrl + Constants.facebookPages);
      final headers = await _getHeaders();

      debugPrint('🌐 Getting Facebook pages from: $url');

      final response = await http.get(url, headers: headers);

      final data = await _handleResponse(response);

      List<FacebookPage> pages = [];

      // Gérer les différents formats de réponse
      if (data.containsKey('pages') && data['pages'] is List) {
        pages = _parsePagesList(data['pages'] as List);
      } else if (data.containsKey('data') && data['data'] is List) {
        pages = _parsePagesList(data['data'] as List);
      } else if (data is List) {
        pages = _parsePagesList(data as List);
      } else if (data.containsKey('success') && data['success'] == true) {
        // Si la réponse est une Map avec success=true mais sans données, retourner liste vide
        pages = [];
      }

      // Mettre en cache
      _cache[cacheKey] = pages;
      _lastCacheUpdate = DateTime.now();

      debugPrint('✅ Retrieved ${pages.length} Facebook pages');
      return pages;
    } catch (e) {
      debugPrint('❌ Get Facebook pages error: $e');
      // Retourner une liste vide plutôt que de planter
      return [];
    }
  }

  Future<bool> selectFacebookPage({
    required String pageId,
    String? pageName,
  }) async {
    try {
      // CORRECTION ICI : Utiliser Constants.apiBaseUrl + Constants.facebookPagesSelect
      final url = Uri.parse(
        Constants.apiBaseUrl + Constants.facebookPagesSelect,
      );
      final headers = await _getHeaders();

      final body = {'page_id': pageId};
      if (pageName != null) body['page_name'] = pageName;

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      final data = await _handleResponse(response);

      // Invalider le cache
      _cache.remove('facebook_pages');

      return (data['success'] ?? false);
    } catch (e) {
      debugPrint('❌ Select Facebook page error: $e');
      return false;
    }
  }

  // ==================== GESTION DES COMMENTAIRES ====================

  Future<List<FacebookComment>> getComments({
    String? pageId,
    String? status,
    String? intent,
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'comments_${pageId}_${status}_$offset';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (cached is List<FacebookComment>) {
        return cached;
      }
    }

    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (pageId != null) params['page_id'] = pageId;
      if (status != null) params['status'] = status;
      if (intent != null) params['intent'] = intent;

      // CORRECTION ICI : Utiliser Constants.apiBaseUrl + Constants.facebookComments
      final url = Uri.parse(
        Constants.apiBaseUrl + Constants.facebookComments,
      ).replace(queryParameters: params);

      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      final data = await _handleResponse(response);

      final List<FacebookComment> comments = [];

      if (data.containsKey('comments') && data['comments'] is List) {
        final commentsList = data['comments'] as List;
        comments.addAll(_parseCommentsList(commentsList));
      } else if (data is List) {
        comments.addAll(_parseCommentsList(data as List));
      } else if (data.containsKey('success') && data['success'] == true) {
        // Si la réponse est une Map avec success=true mais sans données, retourner liste vide
        return [];
      }

      // Mettre en cache
      _cache[cacheKey] = comments;

      return comments;
    } catch (e) {
      debugPrint('❌ Get Facebook comments error: $e');
      return [];
    }
  }

  // ==================== PARSING ====================

  List<FacebookPage> _parsePagesList(List<dynamic> pagesList) {
    final List<FacebookPage> pages = [];

    for (var item in pagesList) {
      try {
        if (item is Map) {
          final pageData = Map<String, dynamic>.from(item);
          pages.add(_parsePageData(pageData));
        }
      } catch (e) {
        debugPrint('⚠️ Error parsing page item: $e');
      }
    }

    return pages;
  }

  FacebookPage _parsePageData(Map<String, dynamic> data) {
    return FacebookPage(
      id: data['id']?.toString() ?? '',
      pageId: data['page_id']?.toString() ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Page sans nom',
      category: data['category']?.toString(),
      about: data['about']?.toString(),
      coverPhotoUrl: data['cover_photo_url']?.toString(),
      profilePicUrl: data['profile_pic_url']?.toString(),
      fanCount: (data['fan_count'] ?? 0) as int,
      pageAccessToken: data['page_access_token']?.toString() ?? '',
      tokenExpiresAt: DateTime.now().add(const Duration(days: 60)),
      facebookUserId: data['facebook_user_id']?.toString() ?? '',
      sellerId: data['seller_id']?.toString() ?? '',
      isSelected: (data['is_selected'] ?? false) == true,
      autoReplyEnabled: (data['auto_reply_enabled'] ?? false) == true,
      autoProcessComments: (data['auto_process_comments'] ?? false) == true,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  List<FacebookComment> _parseCommentsList(List<dynamic> commentsList) {
    final List<FacebookComment> comments = [];

    for (var item in commentsList) {
      try {
        if (item is Map) {
          final commentData = Map<String, dynamic>.from(item);
          comments.add(FacebookComment.fromJson(commentData));
        }
      } catch (e) {
        debugPrint('⚠️ Error parsing comment item: $e');
      }
    }

    return comments;
  }

  // ==================== GESTION DU CACHE ====================

  void _clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
    debugPrint('🧹 Cache cleared');
  }

  void _clearCommentCache() {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith('comments_'))
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  // ==================== MÉTHODES UTILES ====================

  Future<bool> checkFacebookConnection() async {
    try {
      final pages = await getFacebookPages();
      return pages.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Check Facebook connection error: $e');
      return false;
    }
  }

  Future<FacebookPage?> getSelectedPage() async {
    final pages = await getFacebookPages();
    return pages.firstWhereOrNull((p) => p.isSelected) ??
        (pages.isNotEmpty ? pages.first : null);
  }

  Future<FacebookPage?> getPageById(String pageId) async {
    final pages = await getFacebookPages();
    return pages.firstWhereOrNull((p) => p.pageId == pageId);
  }

  // ==================== PROPRIÉTÉS UTILES ====================

  DateTime? get lastCacheUpdate => _lastCacheUpdate;
  int get cacheSize => _cache.length;
}

// Extension pour List
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
