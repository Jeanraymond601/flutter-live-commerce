// lib/services/facebook_service.dart - VERSION SIMPLIFIÉE
import 'dart:convert';
import 'dart:async';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:commerce/models/facebook_models.dart';
import 'package:commerce/services/auth_service.dart';

class FacebookService {
  final AuthService _authService;

  FacebookService(this._authService);

  // ==================== AUTH TOKEN ====================

  String get _token {
    final token = _authService.authToken;
    return token ?? '';
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
    };
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final url = '${Constants.apiBaseUrl}$endpoint';

    if (queryParams == null || queryParams.isEmpty) {
      return Uri.parse(url);
    }

    return Uri.parse(url).replace(queryParameters: queryParams);
  }

  // ==================== RESPONSE HANDLING ====================

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    debugPrint(
      'Facebook API: ${response.statusCode} ${response.request?.url.path}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = json.decode(response.body);
        return decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : {'data': decoded, 'success': true};
      } catch (e) {
        return {'success': true, 'message': 'Operation successful'};
      }
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else if (response.statusCode == 404) {
      return {'success': true, 'data': []}; // Retourner une liste vide
    } else {
      debugPrint('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // ==================== AUTHENTIFICATION ====================

  Future<FacebookConnectResponse> connectToFacebook() async {
    try {
      final url = _buildUri(Constants.facebookLogin);
      debugPrint('Facebook Connect URL: $url');

      final response = await http.get(url, headers: _getHeaders());
      final data = await _handleResponse(response);
      return FacebookConnectResponse.fromJson(data);
    } catch (e) {
      debugPrint('Facebook connection error: $e');
      rethrow;
    }
  }

  Future<bool> disconnectFacebook() async {
    try {
      final url = _buildUri(Constants.facebookDisconnect);
      final response = await http.get(url, headers: _getHeaders());
      final data = await _handleResponse(response);
      return data['success'] ?? false;
    } catch (e) {
      debugPrint('Facebook disconnect error: $e');
      return false;
    }
  }

  // ==================== PAGES MANAGEMENT ====================

  Future<List<FacebookPage>> getFacebookPages() async {
    try {
      final url = _buildUri(Constants.facebookPages);
      debugPrint('Getting Facebook pages from: $url');

      final response = await http.get(url, headers: _getHeaders());
      final data = await _handleResponse(response);

      List<FacebookPage> pages = [];

      if (data.containsKey('pages') && data['pages'] is List) {
        pages = _parsePagesList(data['pages'] as List);
      } else if (data.containsKey('data') && data['data'] is List) {
        pages = _parsePagesList(data['data'] as List);
      } else if (data is List) {
        pages = _parsePagesList(data as List);
      }

      debugPrint('✅ Parsed ${pages.length} Facebook pages');
      return pages;
    } catch (e) {
      debugPrint('❌ Get Facebook pages error: $e');
      return [];
    }
  }

  // CORRECTION: Méthode pour sélectionner une page avec pageName
  Future<bool> selectFacebookPage({
    required String pageId,
    required String pageName,
  }) async {
    try {
      final url = _buildUri(Constants.facebookPagesSelect);
      debugPrint('Selecting page: $pageId - $pageName');

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'page_id': pageId,
          'page_name': pageName, // ⬅️ CHAMP REQUIS
        }),
      );

      final data = await _handleResponse(response);
      return data['success'] ?? false;
    } catch (e) {
      debugPrint('Select Facebook page error: $e');
      return false;
    }
  }

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
      isSelected: data['is_selected'] == true,
      autoReplyEnabled: data['auto_reply_enabled'] == true,
      autoProcessComments: data['auto_process_comments'] ?? false,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  // ==================== COMMENTS MANAGEMENT ====================

  Future<List<FacebookComment>> getComments({
    String? pageId,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{};
      if (pageId != null) params['page_id'] = pageId;
      if (status != null) params['status'] = status;
      params['limit'] = limit.toString();
      params['offset'] = offset.toString();

      final url = _buildUri(Constants.facebookComments, params);
      debugPrint('Getting comments from: $url');

      final response = await http.get(url, headers: _getHeaders());
      final data = await _handleResponse(response);

      final List<FacebookComment> comments = [];

      if (data.containsKey('comments') && data['comments'] is List) {
        final commentsList = data['comments'] as List;
        for (var comment in commentsList) {
          if (comment is Map) {
            comments.add(
              FacebookComment.fromJson(Map<String, dynamic>.from(comment)),
            );
          }
        }
      }

      return comments;
    } catch (e) {
      debugPrint('Get Facebook comments error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> replyToComment({
    required String commentId,
    required String message,
    bool isPrivate = false,
  }) async {
    try {
      final url = _buildUri(
        '${Constants.apiPrefix}/facebook/comments/$commentId/reply',
      );

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({'message': message, 'is_private': isPrivate}),
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint('Reply to comment error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== STATS ====================

  Future<Map<String, dynamic>> getFacebookStats() async {
    try {
      final pages = await getFacebookPages();
      final totalPages = pages.length;
      final connectedPages = pages
          .where((page) => page.pageAccessToken.isNotEmpty)
          .length;

      // Récupérer les commentaires pour la page sélectionnée
      int pendingComments = 0;
      int highPriorityComments = 0;

      final selectedPage = pages.firstWhereOrNull((p) => p.isSelected);
      if (selectedPage != null) {
        final comments = await getComments(
          pageId: selectedPage.pageId,
          status: 'new',
        );
        pendingComments = comments.length;
        highPriorityComments = comments
            .where((comment) => comment.priority == 'high')
            .length;
      }

      return {
        'total_pages': totalPages,
        'connected_pages': connectedPages,
        'pending_comments': pendingComments,
        'high_priority_comments': highPriorityComments,
      };
    } catch (e) {
      debugPrint('Get Facebook stats error: $e');
      return {
        'total_pages': 0,
        'connected_pages': 0,
        'pending_comments': 0,
        'high_priority_comments': 0,
      };
    }
  }

  // ==================== PAGE SETTINGS ====================

  Future<bool> updatePageSettings({
    required String pageId,
    bool? autoReplyEnabled,
    bool? autoProcessComments,
  }) async {
    try {
      final url = _buildUri(
        '${Constants.apiPrefix}/facebook/pages/$pageId/settings',
      );

      final Map<String, dynamic> body = {};
      if (autoReplyEnabled != null) {
        body['auto_reply_enabled'] = autoReplyEnabled;
      }
      if (autoProcessComments != null) {
        body['auto_process_comments'] = autoProcessComments;
      }

      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: json.encode(body),
      );

      final data = await _handleResponse(response);
      return data['success'] ?? false;
    } catch (e) {
      debugPrint('Update page settings error: $e');
      return false;
    }
  }

  // ==================== SYNC ====================

  Future<Map<String, dynamic>> syncFacebookData({
    required String pageId,
  }) async {
    try {
      final url = _buildUri(Constants.facebookSync);

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({'page_id': pageId}),
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint('Sync Facebook data error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== MÉTHODES UTILES ====================

  Future<bool> checkFacebookConnection() async {
    try {
      final pages = await getFacebookPages();
      return pages.isNotEmpty;
    } catch (e) {
      debugPrint('Check Facebook connection error: $e');
      return false;
    }
  }

  Future<FacebookPage?> getSelectedPage() async {
    try {
      final pages = await getFacebookPages();
      return pages.firstWhereOrNull((p) => p.isSelected) ??
          (pages.isNotEmpty ? pages.first : null);
    } catch (e) {
      debugPrint('Get selected page error: $e');
      return null;
    }
  }

  Future<List<FacebookComment>> getPendingComments() async {
    return getComments(status: 'new');
  }

  Future<List<FacebookComment>> getHighPriorityComments() async {
    try {
      final comments = await getComments(status: 'new');
      return comments.where((comment) => comment.priority == 'high').toList();
    } catch (e) {
      debugPrint('Get high priority comments error: $e');
      return [];
    }
  }

  // ==================== MÉTHODES SIMPLIFIÉES ====================

  Future<void> fullSync(String pageId) async {
    try {
      await syncFacebookData(pageId: pageId);
    } catch (e) {
      debugPrint('Full sync error: $e');
      rethrow;
    }
  }
}

// Extension utilitaire
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
