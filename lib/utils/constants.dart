// lib/constants/constants.dart
class Constants {
  // ================================
  // URL DE BASE - PRODUCTION
  // ================================
  static const String apiBaseUrl = 'https://9cbb628e8ee7.ngrok-free.app';

  static const String apiPrefix = '/api/v1';

  // ================================
  // ENDPOINTS FACEBOOK COMPLETS
  // ================================

  // ====================
  // AUTHENTIFICATION & CONNEXION
  // ====================

  // 1. GET /api/v1/facebook/login → Générer URL OAuth
  static const String facebookLogin = '$apiPrefix/facebook/login';

  // 2. GET /api/v1/facebook/callback → Callback OAuth
  static const String facebookCallback = '$apiPrefix/facebook/callback';

  // 3. GET /api/v1/facebook/disconnect → Déconnexion Facebook
  static const String facebookDisconnect = '$apiPrefix/facebook/disconnect';

  // ====================
  // GESTION DES PAGES
  // ====================

  // 4. GET /api/v1/facebook/pages → Liste des pages Facebook
  static const String facebookPages = '$apiPrefix/facebook/pages';

  // 5. POST /api/v1/facebook/pages/select → Sélectionner une page
  static const String facebookPagesSelect = '$apiPrefix/facebook/pages/select';

  // ====================
  // WEBHOOK MANAGEMENT
  // ====================

  // 6. POST /api/v1/facebook/webhook/subscribe → Souscrire aux webhooks
  static const String facebookWebhookSubscribe =
      '$apiPrefix/facebook/webhook/subscribe';

  // 7. GET /api/v1/facebook/webhook → Validation webhook (GET)
  static const String facebookWebhook = '$apiPrefix/facebook/webhook';

  // 8. POST /api/v1/facebook/webhook → Réception webhook (POST)
  static const String facebookWebhookReceive = '$apiPrefix/facebook/webhook';

  // 9. GET /api/v1/facebook/webhook/stream → Stream SSE temps réel
  static const String facebookWebhookStream =
      '$apiPrefix/facebook/webhook/stream';

  // 10. GET /api/v1/facebook/webhook/health → Vérifier état webhooks
  static const String facebookWebhookHealth =
      '$apiPrefix/facebook/webhook/health';

  // ====================
  // SYNCHRONISATION DONNÉES
  // ====================

  // 11. POST /api/v1/facebook/sync → Synchroniser données Facebook
  static const String facebookSync = '$apiPrefix/facebook/sync';

  // 12. POST /api/v1/facebook/sync/start-periodic → Démarrer sync périodique
  static const String facebookSyncStartPeriodic =
      '$apiPrefix/facebook/sync/start-periodic';

  // ====================
  // GESTION DES COMMENTAIRES
  // ====================

  // 13. GET /api/v1/facebook/comments → Liste commentaires avec filtres
  static const String facebookComments = '$apiPrefix/facebook/comments';

  // 14. POST /api/v1/facebook/comments/bulk-process → Traitement en masse
  static const String facebookCommentsBulkProcess =
      '$apiPrefix/facebook/comments/bulk-process';

  // ====================
  // GESTION DES MESSAGES
  // ====================

  // 15. POST /api/v1/facebook/messages/{id}/reply → Répondre à un message
  static String facebookMessageReply(String messageId) =>
      '$apiPrefix/facebook/messages/$messageId/reply';

  // ====================
  // LIVE COMMERCE ANALYTICS
  // ====================

  // 16. GET /api/v1/facebook/live/{id}/analytics → Analytics live vidéo
  static String facebookLiveAnalytics(String liveId) =>
      '$apiPrefix/facebook/live/$liveId/analytics';

  // ====================
  // EXPORT DONNÉES
  // ====================

  // 17. GET /api/v1/facebook/export/comments → Exporter commentaires
  static const String facebookExportComments =
      '$apiPrefix/facebook/export/comments';

  // ====================
  // NOTIFICATIONS
  // ====================

  // 18. GET /api/v1/facebook/notifications/recent → Notifications récentes
  static const String facebookNotificationsRecent =
      '$apiPrefix/facebook/notifications/recent';

  // ====================
  // DEBUG & MONITORING
  // ====================

  // 19. GET /api/v1/facebook/debug/seller-info → Info debug vendeur
  static const String facebookDebugSellerInfo =
      '$apiPrefix/facebook/debug/seller-info';

  // ================================
  // ENDPOINTS D'AUTHENTIFICATION
  // ================================
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyResetCode = '/auth/verify-reset-code';
  static const String authResetPassword = '/auth/reset-password';

  // Ajout du paramètre email
  static String authCheckEmail(String email) => '/auth/check-email/$email';

  // ================================
  // ENDPOINTS DES PRODUITS - CORRIGÉ
  // ================================

  // 1) POST /products/ → Créer un produit avec génération auto de code
  static const String productsCreate = '/products/';

  // 2) GET /products/seller/{identifier} → Lister les produits d'un vendeur
  //    Accepte soit seller_id (UUID) soit user_id (UUID)
  static String productsBySeller(String identifier) =>
      '/products/seller/$identifier';

  // 3) GET /products/{product_id} → Récupérer un produit par son ID (pas par code)
  static String productsById(String productId) => '/products/$productId';

  // 4) GET /products/filter → Filtrage multi-critères avec pagination
  static const String productsFilter = '/products/filter';

  // 5) PATCH /products/{id} → Mettre à jour un produit (PATCH au lieu de PUT)
  static String productsUpdate(String productId) => '/products/$productId';

  // 6) DELETE /products/{id} → Supprimer un produit
  static String productsDelete(String productId) => '/products/$productId';

  // 7) GET /products/search → Recherche texte (nom, description, catégorie)
  static const String productsSearch = '/products/search';

  // 8) GET /products/seller/{identifier}/stats → Statistiques produits vendeur
  static String productsSellerStats(String identifier) =>
      '/products/seller/$identifier/stats';

  // 9) GET /products/seller/{identifier}/categories → Catégories utilisées
  static String productsSellerCategories(String identifier) =>
      '/products/seller/$identifier/categories';

  // 10) POST /products/generate-code → Générer un code article
  static const String productsGenerateCode = '/products/generate-code';

  // 11) GET /products/my-products → Mes produits (vendeur connecté)
  static const String productsMyProducts = '/products/my-products';

  // 12) GET /products/debug/current-seller → Debug info vendeur
  static const String productsDebugSeller = '/products/debug/current-seller';

  // 13) GET /products/test/resolve/{identifier} → Test résolution d'identifiant
  static String productsTestResolve(String identifier) =>
      '/products/test/resolve/$identifier';

  // ================================
  // ENDPOINTS DES LIVREURS (DRIVERS)
  // ================================

  // 1) GET /api/v1/drivers/test → Test des permissions
  static const String driversTest = '$apiPrefix/drivers/test';

  // 2) POST /api/v1/drivers/ → Créer un nouveau livreur
  static const String driversCreate = '$apiPrefix/drivers/';

  // 3) GET /api/v1/drivers/ → Liste des livreurs du vendeur
  static const String driversList = '$apiPrefix/drivers/';

  // 4) GET /api/v1/drivers/{driver_id} → Détails d'un livreur
  static String driversDetail(String driverId) =>
      '$apiPrefix/drivers/$driverId';

  // 5) PUT /api/v1/drivers/{driver_id} → Mettre à jour un livreur
  static String driversUpdate(String driverId) =>
      '$apiPrefix/drivers/$driverId';

  // 6) PATCH /api/v1/drivers/{driver_id}/activate → Activer un livreur
  static String driversActivate(String driverId) =>
      '$apiPrefix/drivers/$driverId/activate';

  // 7) PATCH /api/v1/drivers/{driver_id}/suspend → Suspendre un livreur
  static String driversSuspend(String driverId) =>
      '$apiPrefix/drivers/$driverId/suspend';

  // 8) DELETE /api/v1/drivers/{driver_id} → Supprimer un livreur (soft delete)
  static String driversDelete(String driverId) =>
      '$apiPrefix/drivers/$driverId';

  // 9) GET /api/v1/drivers/stats/summary → Statistiques des livreurs
  static const String driversStatsSummary = '$apiPrefix/drivers/stats/summary';

  // 10) GET /api/v1/drivers/zones/available → Zones de livraison disponibles
  static const String driversZonesAvailable =
      '$apiPrefix/drivers/zones/available';

  // 11) POST /api/v1/drivers/{driver_id}/update-geolocation → Mettre à jour géolocalisation
  static String driversUpdateGeolocation(String driverId) =>
      '$apiPrefix/drivers/$driverId/update-geolocation';

  // ================================
  // NOUVEAUX MESSAGES FACEBOOK
  // ================================

  static const String successFacebookConnected = 'Connexion Facebook réussie !';
  static const String successFacebookPageSelected =
      'Page Facebook sélectionnée !';
  static const String successFacebookWebhookSubscribed =
      'Webhooks activés avec succès !';
  static const String successFacebookSyncStarted = 'Synchronisation démarrée !';
  static const String successMessageSent = 'Message envoyé !';
  static const String successCommentReplied = 'Réponse publiée !';

  static const String errorFacebookConnection = 'Erreur de connexion Facebook';
  static const String errorFacebookTokenExpired = 'Token Facebook expiré';
  static const String errorFacebookPageNotFound = 'Page Facebook non trouvée';
  static const String errorFacebookNoPermissions =
      'Permissions Facebook insuffisantes';
  static const String errorFacebookWebhookFailed =
      'Erreur d\'activation des webhooks';
  static const String errorMessageSendFailed = 'Erreur d\'envoi du message';

  // ================================
  // GESTION DES ERREURS HTTP
  // ================================
  static const int httpSuccess = 200;
  static const int httpCreated = 201;
  static const int httpNoContent = 204;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;
  static const int httpMethodNotAllowed = 405;

  // ================================
  // CONFIGURATION PAGINATION
  // ================================
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // ================================
  // MESSAGES D'ERREUR
  // ================================
  static const String errorNetwork =
      'Erreur de connexion. Vérifiez votre internet.';
  static const String errorServer =
      'Erreur serveur. Veuillez réessayer plus tard.';
  static const String errorUnauthorized =
      'Session expirée. Veuillez vous reconnecter.';
  static const String errorNotFound = 'Ressource non trouvée.';
  static const String errorValidation =
      'Veuillez vérifier les informations saisies.';
  static const String errorMethodNotAllowed = 'Méthode HTTP non autorisée';
  static const String errorSlashMissing =
      'Erreur de format d\'URL. Vérifiez la configuration.';

  // Nouveaux messages pour les livreurs
  static const String errorDriverCreation =
      'Erreur lors de la création du livreur.';
  static const String errorDriverUpdate =
      'Erreur lors de la mise à jour du livreur.';
  static const String errorDriverNotFound = 'Livreur non trouvé.';
  static const String errorZoneDetection =
      'Impossible de détecter la zone. Vérifiez l\'adresse.';
  static const String errorEmailAlreadyUsed = 'Email déjà utilisé.';

  // Messages d'erreur pour les produits
  static const String errorProductCreation =
      'Erreur lors de la création du produit.';
  static const String errorProductUpdate =
      'Erreur lors de la mise à jour du produit.';
  static const String errorProductNotFound = 'Produit non trouvé.';
  static const String errorProductCodeGeneration =
      'Erreur lors de la génération du code.';
  static const String errorProductDeletion =
      'Erreur lors de la suppression du produit.';
  static const String errorCategoryEmpty =
      'La catégorie ne peut pas être vide.';
  static const String errorPriceInvalid = 'Le prix doit être supérieur à 0.';
  static const String errorStockInvalid = 'Le stock ne peut pas être négatif.';
  static const String errorCodeAlreadyExists = 'Ce code article existe déjà.';

  // ================================
  // MESSAGES DE SUCCÈS
  // ================================
  static const String successProductCreated = 'Produit créé avec succès !';
  static const String successProductUpdated =
      'Produit mis à jour avec succès !';
  static const String successProductDeleted = 'Produit supprimé avec succès !';
  static const String successProductActivated = 'Produit activé avec succès !';
  static const String successProductDeactivated =
      'Produit désactivé avec succès !';
  static const String successCodeGenerated = 'Code généré avec succès !';
  static const String successCategoryManaged =
      'Catégorie gérée automatiquement.';

  // Nouveaux messages pour les livreurs
  static const String successDriverCreated = 'Livreur créé avec succès !';
  static const String successDriverUpdated = 'Livreur mis à jour avec succès !';
  static const String successDriverDeleted = 'Livreur supprimé avec succès !';
  static const String successDriverActivated = 'Livreur activé avec succès !';
  static const String successDriverSuspended = 'Livreur suspendu avec succès !';
  static const String successZoneDetected = 'Zone détectée avec succès !';
  static const String successGeolocationUpdated =
      'Géolocalisation mise à jour avec succès !';

  // ================================
  // CONFIRMATION DIALOGS
  // ================================

  // Facebook dialogs
  static const String confirmFacebookDisconnectTitle = 'Déconnexion Facebook';
  static const String confirmFacebookDisconnectMessage =
      'Êtes-vous sûr de vouloir déconnecter votre compte Facebook ? Toutes les données seront supprimées.';

  static const String confirmWebhookSubscribeTitle = 'Activer les webhooks';
  static const String confirmWebhookSubscribeMessage =
      'Activer les webhooks Facebook permet de recevoir les notifications en temps réel. Continuer ?';

  // Produits
  static const String confirmDeleteTitle = 'Supprimer le produit';
  static const String confirmDeleteMessage =
      'Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.';
  static const String confirmDeactivateTitle = 'Désactiver le produit';
  static const String confirmDeactivateMessage =
      'Êtes-vous sûr de vouloir désactiver ce produit ? Il ne sera plus visible pour les clients.';
  static const String confirmActivateTitle = 'Activer le produit';
  static const String confirmActivateMessage =
      'Activer ce produit le rendra visible pour les clients.';

  // Livreurs
  static const String confirmDeleteDriverTitle = 'Supprimer le livreur';
  static const String confirmDeleteDriverMessage =
      'Êtes-vous sûr de vouloir supprimer ce livreur ? Cette action est irréversible.';
  static const String confirmSuspendDriverTitle = 'Suspendre le livreur';
  static const String confirmSuspendDriverMessage =
      'Êtes-vous sûr de vouloir suspendre ce livreur ? Il ne pourra plus effectuer de livraisons.';
  static const String confirmActivateDriverTitle = 'Activer le livreur';
  static const String confirmActivateDriverMessage =
      'Activer ce livreur lui permettra de recevoir des missions de livraison.';

  // ================================
  // CONFIGURATION DE L'APPLICATION
  // ================================
  static const String uncategorizedId = 'uncategorized';

  static const String appName = 'Live Commerce';
  static const String appVersion = '1.0.0';

  // Temps de rafraîchissement (en millisecondes)
  static const int refreshDelay = 300;

  // Durée d'affichage des snackbars (en secondes)
  static const int snackbarDuration = 3;

  // ================================
  // FORMATS DE DONNÉES
  // ================================
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencySymbol = 'Ar';
  static const String decimalSeparator = '.';
  static const String thousandSeparator = ' ';

  // ================================
  // CONFIGURATION API POUR DÉVELOPPEMENT
  // ================================

  // URL alternatives selon l'environnement
  static String getApiUrl() {
    return apiBaseUrl;
  }

  // Headers communs pour toutes les requêtes
  static Map<String, String> getDefaultHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ================================
  // CONFIGURATION DES PRODUITS
  // ================================

  // Catégories courantes pour suggestions
  static const List<String> commonCategories = [
    'Électronique',
    'Vêtements',
    'Maison',
    'Sport',
    'Livres',
    'Informatique',
    'Téléphonie',
    'Beauté',
    'Santé',
    'Jardin',
    'Bricolage',
    'Automobile',
    'Alimentation',
    'Boissons',
    'Enfants',
    'Animaux',
    'Musique',
    'Films',
    'Jeux vidéo',
  ];

  // Tailles courantes
  static const List<String> commonSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '32GB',
    '64GB',
    '128GB',
    '256GB',
    '512GB',
    '1TB',
    '36',
    '38',
    '40',
    '42',
    '44',
    '46',
    'Unique',
  ];

  // Couleurs courantes
  static const List<String> commonColors = [
    'Noir',
    'Blanc',
    'Rouge',
    'Bleu',
    'Vert',
    'Jaune',
    'Orange',
    'Violet',
    'Rose',
    'Marron',
    'Gris',
    'Argent',
    'Or',
    'Beige',
    'Turquoise',
    'Multicolor',
  ];

  // ================================
  // CONFIGURATION DES LIVREURS
  // ================================

  // Statuts possibles pour les livreurs
  static const List<String> driverStatuses = [
    'actif',
    'en_attente',
    'suspendu',
    'rejeté',
  ];

  // Zones de livraison communes à Madagascar (pour suggestions)
  static const List<String> commonZonesMadagascar = [
    'Antananarivo Centre',
    'Antananarivo Avaradrano',
    'Antananarivo Atsimondrano',
    'Antananarivo Renivohitra',
    'Antananarivo - Analakely',
    'Antananarivo - Isotry',
    'Antananarivo - Andohalo',
    'Toamasina I',
    'Toamasina II',
    'Mahajanga I',
    'Mahajanga II',
    'Toliara I',
    'Toliara II',
    'Antsiranana I',
    'Antsiranana II',
    'Fianarantsoa I',
    'Fianarantsoa II',
    'Antsirabe I',
    'Antsirabe II',
    'Ambositra',
    'Morondava',
    'Sainte-Marie',
    'Nosy Be',
  ];

  // Codes postaux Madagascar pour aide à la saisie
  static const Map<String, String> postalCodeToZone = {
    '101': 'Antananarivo Centre',
    '102': 'Antananarivo Avaradrano',
    '103': 'Antananarivo Atsimondrano',
    '104': 'Antananarivo Renivohitra',
    '105': 'Antananarivo',
    '201': 'Antsiranana I',
    '202': 'Antsiranana II',
    '301': 'Fianarantsoa I',
    '302': 'Fianarantsoa II',
    '401': 'Mahajanga I',
    '402': 'Mahajanga II',
    '501': 'Toamasina I',
    '502': 'Toamasina II',
    '601': 'Toliara I',
    '602': 'Toliara II',
    '110': 'Antsirabe I',
    '111': 'Antsirabe II',
    '306': 'Ambositra',
    '307': 'Ambositra',
    '514': 'Sainte-Marie',
    '515': 'Sainte-Marie',
    '619': 'Morondava',
    '620': 'Morondava',
  };

  // ================================
  // VALIDATION DES FORMULAIRES
  // ================================

  // Patterns de validation
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(r'^[0-9]{10}$');

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Validation pour les produits
  static final RegExp productCodeRegex = RegExp(r'^[A-Z]{3}\d{3}$');
  static final RegExp priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');

  // Messages de validation
  static const String validationRequired = 'Ce champ est obligatoire';
  static const String validationEmail = 'Veuillez entrer un email valide';
  static const String validationPhone =
      'Veuillez entrer un numéro valide (10 chiffres)';
  static const String validationPassword =
      'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial';
  static const String validationAddress =
      'L\'adresse doit contenir au moins 10 caractères';
  static const String validationProductName =
      'Le nom doit contenir au moins 3 caractères';
  static const String validationProductCategory =
      'La catégorie est obligatoire';
  static const String validationProductPrice =
      'Le prix doit être supérieur à 0';
  static const String validationProductStock =
      'Le stock ne peut pas être négatif';
  static const String validationProductCode = 'Format invalide (ex: ABC123)';

  // ================================
  // MÉTHODES UTILITAIRES POUR LES URLS
  // ================================

  /// Méthode utilitaire pour construire une URL avec des paramètres de query
  /// Exemple: buildUrlWithParams(Constants.driversList, {'page': 1, 'page_size': 20})
  static String buildUrlWithParams(
    String baseUrl,
    Map<String, dynamic> params,
  ) {
    if (params.isEmpty) return baseUrl;

    final queryString = params.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) =>
              '${entry.key}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');

    return '$baseUrl?$queryString';
  }

  /// Méthode pour s'assurer qu'une URL a un slash à la fin si nécessaire
  static String ensureTrailingSlash(String url, {bool needsSlash = true}) {
    if (needsSlash && !url.endsWith('/')) {
      return '$url/';
    } else if (!needsSlash && url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Construire l'URL complète avec la base
  static String buildFullUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  /// URL complète pour les endpoints Facebook
  static String getFacebookUrl(String endpoint) {
    return buildFullUrl(endpoint);
  }

  /// URL complète pour les endpoints de livreurs
  static String getDriversListUrl(Map<String, dynamic>? params) {
    final baseUrl = buildFullUrl(driversList);
    if (params == null || params.isEmpty) return baseUrl;
    return buildUrlWithParams(baseUrl, params);
  }

  /// URL complète pour les endpoints de produits
  static String getProductsListUrl(Map<String, dynamic>? params) {
    final baseUrl = buildFullUrl(productsFilter);
    if (params == null || params.isEmpty) return baseUrl;
    return buildUrlWithParams(baseUrl, params);
  }

  /// URL pour détecter la zone depuis une adresse (simulation)
  static String getZoneDetectionUrl(String address) {
    // Note: Cette fonctionnalité est intégrée dans l'endpoint de création
    // Pour une détection standalone, vous pourriez créer un endpoint dédié
    return buildFullUrl(
      driversCreate,
    ); // Utilise le même endpoint avec logique spéciale
  }

  // ================================
  // CONFIGURATION UI/UX
  // ================================

  // Durées d'animation (en millisecondes)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Délais (en millisecondes)
  static const int debounceDelay = 500; // Pour la recherche
  static const int typingDelay = 300; // Pour la détection de zone
  static const int productSearchDelay = 300; // Recherche produits

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double driverCardHeight = 120.0;
  static const double driverAvatarSize = 50.0;
  static const double productCardHeight = 150.0;
  static const double productImageSize = 80.0;

  // Couleurs pour les statuts
  static const Map<String, int> statusColors = {
    'actif': 0xFF4CAF50, // Vert
    'en_attente': 0xFFFF9800, // Orange
    'suspendu': 0xFFF44336, // Rouge
    'rejeté': 0xFF9E9E9E, // Gris
  };

  // Couleurs pour statuts produits
  static const Map<String, int> productStatusColors = {
    'active': 0xFF4CAF50, // Vert
    'inactive': 0xFFF44336, // Rouge
    'low_stock': 0xFFFF9800, // Orange (stock faible)
  };

  // Couleurs pour Facebook
  static const Map<String, int> facebookColors = {
    'connected': 0xFF4267B2, // Bleu Facebook
    'disconnected': 0xFF9E9E9E, // Gris
    'pending': 0xFFFF9800, // Orange
    'error': 0xFFF44336, // Rouge
  };

  // Icônes pour les statuts
  static const Map<String, String> statusIcons = {
    'actif': 'check_circle',
    'en_attente': 'pending',
    'suspendu': 'pause_circle',
    'rejeté': 'cancel',
  };

  // Icônes pour produits
  static const Map<String, String> productStatusIcons = {
    'active': 'check_circle',
    'inactive': 'visibility_off',
    'low_stock': 'warning',
  };

  // Icônes pour Facebook
  static const Map<String, String> facebookIcons = {
    'connected': 'facebook',
    'disconnected': 'link_off',
    'page': 'pages',
    'comment': 'comment',
    'message': 'message',
    'live': 'live_tv',
    'notification': 'notifications',
  };

  // ================================
  // MÉTHODES UTILITAIRES POUR LES PRODUITS
  // ================================

  /// Formater le prix avec devise
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} $currencySymbol';
  }

  /// Formater le code produit pour l'affichage
  static String formatProductCode(String code) {
    if (code.length >= 6) {
      return '${code.substring(0, 3)}-${code.substring(3)}';
    }
    return code;
  }

  /// Générer un exemple de code basé sur la catégorie
  static String generateExampleCode(String category) {
    if (category.isEmpty) return 'XXX001';
    final prefix = category.length >= 3
        ? category.substring(0, 3).toUpperCase()
        : '${category.toUpperCase()}XX'.substring(0, 3);
    return '${prefix}001';
  }

  /// Vérifier si le stock est faible
  static bool isLowStock(int stock, {int threshold = 10}) {
    return stock > 0 && stock <= threshold;
  }

  /// Obtenir la couleur selon le statut du stock
  static int getStockColor(int stock) {
    if (stock == 0) return 0xFFF44336; // Rouge pour rupture
    if (stock <= 10) return 0xFFFF9800; // Orange pour faible stock
    return 0xFF4CAF50; // Vert pour stock OK
  }

  /// Obtenir l'icône selon le statut du stock
  static String getStockIcon(int stock) {
    if (stock == 0) return 'error_outline';
    if (stock <= 10) return 'warning';
    return 'check_circle';
  }

  /// Obtenir le message de statut du stock
  static String getStockMessage(int stock) {
    if (stock == 0) return 'Rupture de stock';
    if (stock <= 10) return 'Stock faible';
    return 'En stock';
  }

  // ================================
  // MÉTHODES UTILITAIRES FACEBOOK
  // ================================

  /// Formater la date Facebook
  static String formatFacebookDate(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours} h';
      } else if (difference.inDays < 30) {
        return 'Il y a ${difference.inDays} j';
      } else {
        return 'Le ${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateTime;
    }
  }

  /// Obtenir la couleur selon le sentiment NLP
  static int getSentimentColor(String? sentiment) {
    switch (sentiment?.toLowerCase()) {
      case 'positive':
        return 0xFF4CAF50; // Vert
      case 'negative':
        return 0xFFF44336; // Rouge
      case 'neutral':
        return 0xFF2196F3; // Bleu
      default:
        return 0xFF9E9E9E; // Gris
    }
  }

  /// Obtenir l'icône selon l'intention NLP
  static String getIntentIcon(String? intent) {
    switch (intent?.toLowerCase()) {
      case 'purchase':
        return 'shopping_cart';
      case 'question':
        return 'help_outline';
      case 'complaint':
        return 'warning';
      case 'compliment':
        return 'thumb_up';
      case 'urgent':
        return 'error';
      default:
        return 'chat';
    }
  }

  // ================================
  // PARAMÈTRES DE FILTRAGE PAR DÉFAUT
  // ================================

  /// Paramètres par défaut pour le filtrage des produits
  static Map<String, dynamic> getDefaultProductFilterParams({
    String? sellerId,
    String? categoryName,
    bool? isActive,
    double? priceMin,
    double? priceMax,
    String? search,
    int page = 1,
    int size = 20,
    String sortBy = 'created_at',
    bool sortDesc = true,
  }) {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sort_by': sortBy,
      'sort_desc': sortDesc,
    };

    if (sellerId != null && sellerId.isNotEmpty) {
      params['seller_id'] = sellerId;
    }
    if (categoryName != null && categoryName.isNotEmpty) {
      params['category_name'] = categoryName;
    }
    if (isActive != null) {
      params['is_active'] = isActive;
    }
    if (priceMin != null && priceMin > 0) {
      params['price_min'] = priceMin;
    }
    if (priceMax != null && priceMax > 0) {
      params['price_max'] = priceMax;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    return params;
  }

  /// Paramètres par défaut pour les commentaires Facebook
  static Map<String, dynamic> getDefaultFacebookCommentParams({
    String? pageId,
    String? status,
    int limit = 50,
    int offset = 0,
    String? intent,
    String? sentiment,
  }) {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};

    if (pageId != null && pageId.isNotEmpty) {
      params['page_id'] = pageId;
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    if (intent != null && intent.isNotEmpty) {
      params['intent'] = intent;
    }
    if (sentiment != null && sentiment.isNotEmpty) {
      params['sentiment'] = sentiment;
    }

    return params;
  }

  /// Paramètres par défaut pour les notifications Facebook
  static Map<String, dynamic> getDefaultFacebookNotificationParams({
    int limit = 20,
  }) {
    return {'limit': limit};
  }
}
