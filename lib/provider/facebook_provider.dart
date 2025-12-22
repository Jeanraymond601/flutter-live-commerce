// lib/providers/facebook_provider.dart - VERSION CORRIGÉE
import 'package:flutter/widgets.dart';
import 'package:commerce/services/facebook_service.dart';
import 'package:commerce/models/facebook_models.dart';

class FacebookProvider extends ChangeNotifier {
  final FacebookService _facebookService;

  FacebookProvider(this._facebookService);

  // State
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  List<FacebookPage> _pages = [];
  List<FacebookComment> _comments = [];
  FacebookPage? _selectedPage;
  Map<String, dynamic> _stats = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<FacebookPage> get pages => _pages;
  List<FacebookComment> get comments => _comments;
  FacebookPage? get selectedPage => _selectedPage;
  Map<String, dynamic> get stats => _stats;

  // ==================== MÉTHODES UTILITAIRES ====================

  void clearPages() {
    _pages.clear();
    _selectedPage = null;
    _error = null;
    _safeNotifyListeners();
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  void clearComments() {
    _comments.clear();
    _safeNotifyListeners();
  }

  // CORRECTION: Méthode pour notifier après le build
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  // ==================== ACTIONS PRINCIPALES ====================

  Future<void> loadFacebookPages({bool autoSelect = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    // ⚠️ NE PAS notifier ici - sera notifié à la fin async

    try {
      final pages = await _facebookService.getFacebookPages();

      _pages = pages;

      // Trouver la page précédemment sélectionnée
      _selectedPage = null;
      for (var page in _pages) {
        if (page.isSelected) {
          _selectedPage = page;
          break;
        }
      }

      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('Load Facebook pages error: $_error');
    } finally {
      _isLoading = false;
      // CORRECTION: Notifier après la fin de l'opération async
      _safeNotifyListeners();
    }
  }

  Future<void> selectPage(String pageId, {bool force = false}) async {
    final selectedIndex = _pages.indexWhere((p) => p.pageId == pageId);
    if (selectedIndex == -1) return;

    final page = _pages[selectedIndex];
    if (page.isSelected && !force) {
      // Déjà sélectionnée, ne rien faire
      return;
    }

    _isProcessing = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // CORRECTION: Créer une nouvelle liste avec les pages mises à jour
      _pages = _pages.map((p) {
        if (p.pageId == pageId) {
          return p.copyWith(isSelected: true);
        } else {
          return p.copyWith(isSelected: false);
        }
      }).toList();

      _selectedPage = _pages.firstWhere((p) => p.pageId == pageId);

      // Appeler le service avec les deux paramètres
      await _facebookService.selectFacebookPage(
        pageId: pageId,
        pageName: page.name,
      );

      // Charger les commentaires
      await loadComments(forceRefresh: true);

      // Rafraîchir les stats
      await refreshStats();
    } catch (e) {
      // En cas d'erreur, restaurer l'ancien état
      _pages = _pages.map((p) {
        if (p.pageId == pageId) {
          return p.copyWith(isSelected: false);
        }
        return p;
      }).toList();

      _selectedPage = null;
      _error = _getErrorMessage(e);
      debugPrint('Select page error: $_error');
    } finally {
      _isProcessing = false;
      _safeNotifyListeners();
    }
  }

  void deselectAllPages() {
    _pages = _pages.map((page) => page.copyWith(isSelected: false)).toList();
    _selectedPage = null;
    _comments.clear();
    _safeNotifyListeners();
  }

  Future<void> loadComments({bool forceRefresh = false}) async {
    if (_selectedPage == null) {
      return;
    }

    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    // ⚠️ NE PAS notifier ici - sera notifié à la fin

    try {
      _comments = await _facebookService.getComments(
        pageId: _selectedPage!.pageId,
        status: 'new',
      );
    } catch (e) {
      debugPrint('Load comments error: $e');
      _comments = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // ==================== AUTRES ACTIONS ====================

  Future<void> refreshStats() async {
    try {
      final stats = await _facebookService.getFacebookStats();
      _stats = stats;
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Refresh stats error: $e');
    }
  }

  Future<void> updatePageSettings({
    required String pageId,
    bool? autoReplyEnabled,
    bool? autoProcessComments,
  }) async {
    _isProcessing = true;
    _safeNotifyListeners();

    try {
      // Mettre à jour la liste des pages
      _pages = _pages.map((page) {
        if (page.pageId == pageId) {
          return page.copyWith(
            autoReplyEnabled: autoReplyEnabled ?? page.autoReplyEnabled,
            autoProcessComments:
                autoProcessComments ?? page.autoProcessComments,
          );
        }
        return page;
      }).toList();

      // Mettre à jour la page sélectionnée si nécessaire
      if (_selectedPage?.pageId == pageId) {
        _selectedPage = _selectedPage!.copyWith(
          autoReplyEnabled: autoReplyEnabled ?? _selectedPage!.autoReplyEnabled,
          autoProcessComments:
              autoProcessComments ?? _selectedPage!.autoProcessComments,
        );
      }

      // Envoyer la mise à jour au serveur
      await _facebookService.updatePageSettings(
        pageId: pageId,
        autoReplyEnabled: autoReplyEnabled,
        autoProcessComments: autoProcessComments,
      );
    } catch (e) {
      debugPrint('Update page settings error: $e');
    } finally {
      _isProcessing = false;
      _safeNotifyListeners();
    }
  }

  // ==================== MÉTHODES HELPERS ====================

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    if (error != null) return error.toString();
    return 'Une erreur inconnue est survenue';
  }

  void selectFirstPageIfNeeded() {
    if (_pages.isNotEmpty && _selectedPage == null) {
      selectPage(_pages.first.pageId, force: true);
    }
  }
}
