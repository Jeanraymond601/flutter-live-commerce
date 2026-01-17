// models/facebook_models.dart - VERSION COMPLÈTE CORRIGÉE
// ==================== MODÈLES PRINCIPAUX ====================

class FacebookUser {
  final String id;
  final String facebookUserId;
  final String? email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? profilePicUrl;
  final String longLivedToken;
  final DateTime tokenExpiresAt;
  final List<String> grantedPermissions;
  final String? sellerId;
  final bool isActive;
  final DateTime? lastSync;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FacebookUser({
    required this.id,
    required this.facebookUserId,
    this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.profilePicUrl,
    required this.longLivedToken,
    required this.tokenExpiresAt,
    required this.grantedPermissions,
    this.sellerId,
    required this.isActive,
    this.lastSync,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookUser.fromJson(Map<String, dynamic> json) {
    return FacebookUser(
      id: json['id']?.toString() ?? '',
      facebookUserId: json['facebook_user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      longLivedToken: json['long_lived_token']?.toString() ?? '',
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'].toString()) ??
                DateTime.now().add(const Duration(days: 60))
          : DateTime.now().add(const Duration(days: 60)),
      grantedPermissions: List<String>.from(json['granted_permissions'] ?? []),
      sellerId: json['seller_id']?.toString(),
      isActive: json['is_active'] ?? true,
      lastSync: json['last_sync'] != null
          ? DateTime.tryParse(json['last_sync'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facebook_user_id': facebookUserId,
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'profile_pic_url': profilePicUrl,
      'long_lived_token': longLivedToken,
      'token_expires_at': tokenExpiresAt.toIso8601String(),
      'granted_permissions': grantedPermissions,
      'seller_id': sellerId,
      'is_active': isActive,
      'last_sync': lastSync?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class FacebookPage {
  final String id;
  final String pageId;
  final String name;
  final String? category;
  final String? about;
  final String? coverPhotoUrl;
  final String? profilePicUrl;
  final int fanCount;
  final String pageAccessToken;
  final DateTime tokenExpiresAt;
  final String facebookUserId;
  final String sellerId;
  final bool isSelected;
  final bool autoReplyEnabled;
  final bool autoProcessComments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FacebookPage({
    required this.id,
    required this.pageId,
    required this.name,
    this.category,
    this.about,
    this.coverPhotoUrl,
    this.profilePicUrl,
    required this.fanCount,
    required this.pageAccessToken,
    required this.tokenExpiresAt,
    required this.facebookUserId,
    required this.sellerId,
    required this.isSelected,
    required this.autoReplyEnabled,
    required this.autoProcessComments,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookPage.fromJson(Map<String, dynamic> json) {
    // CORRECTION : Gérer l'absence de auto_reply_enabled en utilisant une valeur par défaut
    bool? autoReplyEnabled;

    // Essayer de récupérer la valeur de différentes façons
    if (json['auto_reply_enabled'] != null) {
      if (json['auto_reply_enabled'] is bool) {
        autoReplyEnabled = json['auto_reply_enabled'] as bool;
      } else if (json['auto_reply_enabled'] is String) {
        autoReplyEnabled =
            json['auto_reply_enabled'].toString().toLowerCase() == 'true';
      } else if (json['auto_reply_enabled'] is int) {
        autoReplyEnabled = json['auto_reply_enabled'] == 1;
      }
    }

    // Si toujours null, essayer d'autres champs
    if (autoReplyEnabled == null) {
      if (json.containsKey('auto_reply')) {
        if (json['auto_reply'] is bool) {
          autoReplyEnabled = json['auto_reply'] as bool;
        }
      }
    }

    // CORRECTION : Gérer la conversion des dates
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.tryParse(value);
        } else if (value is DateTime) {
          return value;
        }
      } catch (_) {}
      return null;
    }

    final createdAtValue = parseDateTime(json['created_at']) ?? DateTime.now();
    final tokenExpiresAtValue =
        parseDateTime(json['token_expires_at']) ??
        DateTime.now().add(const Duration(days: 60));

    return FacebookPage(
      id: json['id']?.toString() ?? '',
      pageId: json['page_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Page sans nom',
      category: json['category']?.toString(),
      about: json['about']?.toString(),
      coverPhotoUrl: json['cover_photo_url']?.toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      fanCount: (json['fan_count'] ?? 0) as int,
      pageAccessToken: json['page_access_token']?.toString() ?? '',
      tokenExpiresAt: tokenExpiresAtValue,
      facebookUserId: json['facebook_user_id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      isSelected: (json['is_selected'] ?? false) == true,
      autoReplyEnabled: autoReplyEnabled ?? false, // Valeur par défaut si null
      autoProcessComments: (json['auto_process_comments'] ?? false) == true,
      createdAt: createdAtValue,
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_id': pageId,
      'name': name,
      'category': category,
      'about': about,
      'cover_photo_url': coverPhotoUrl,
      'profile_pic_url': profilePicUrl,
      'fan_count': fanCount,
      'page_access_token': pageAccessToken,
      'token_expires_at': tokenExpiresAt.toIso8601String(),
      'facebook_user_id': facebookUserId,
      'seller_id': sellerId,
      'is_selected': isSelected,
      'auto_reply_enabled': autoReplyEnabled,
      'auto_process_comments': autoProcessComments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // CORRECTION : Méthode pour créer une copie avec des valeurs modifiées
  FacebookPage copyWith({
    String? id,
    String? pageId,
    String? name,
    String? category,
    String? about,
    String? coverPhotoUrl,
    String? profilePicUrl,
    int? fanCount,
    String? pageAccessToken,
    DateTime? tokenExpiresAt,
    String? facebookUserId,
    String? sellerId,
    bool? isSelected,
    bool? autoReplyEnabled,
    bool? autoProcessComments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FacebookPage(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      name: name ?? this.name,
      category: category ?? this.category,
      about: about ?? this.about,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      fanCount: fanCount ?? this.fanCount,
      pageAccessToken: pageAccessToken ?? this.pageAccessToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      facebookUserId: facebookUserId ?? this.facebookUserId,
      sellerId: sellerId ?? this.sellerId,
      isSelected: isSelected ?? this.isSelected,
      autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
      autoProcessComments: autoProcessComments ?? this.autoProcessComments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FacebookPost {
  final String id;
  final String facebookPostId;
  final String? message;
  final String? story;
  final String? postType;
  final String? pictureUrl;
  final String? fullPictureUrl;
  final String? link;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String pageId;
  final String sellerId;
  final DateTime? createdAt;
  final DateTime? facebookCreatedTime;
  final DateTime? updatedAt;
  final bool isHidden;
  final bool isLiveCommerce;
  final List<FacebookComment> comments;

  FacebookPost({
    required this.id,
    required this.facebookPostId,
    this.message,
    this.story,
    this.postType,
    this.pictureUrl,
    this.fullPictureUrl,
    this.link,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.pageId,
    required this.sellerId,
    this.createdAt,
    this.facebookCreatedTime,
    this.updatedAt,
    required this.isHidden,
    required this.isLiveCommerce,
    this.comments = const [],
  });

  factory FacebookPost.fromJson(Map<String, dynamic> json) {
    return FacebookPost(
      id: json['id']?.toString() ?? '',
      facebookPostId:
          json['facebook_post_id']?.toString() ?? json['id']?.toString() ?? '',
      message: json['message']?.toString(),
      story: json['story']?.toString(),
      postType: json['post_type']?.toString(),
      pictureUrl: json['picture_url']?.toString(),
      fullPictureUrl: json['full_picture_url']?.toString(),
      link: json['link']?.toString(),
      likesCount: (json['likes_count'] ?? 0) as int,
      commentsCount: (json['comments_count'] ?? 0) as int,
      sharesCount: (json['shares_count'] ?? 0) as int,
      pageId: json['page_id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      facebookCreatedTime: json['facebook_created_time'] != null
          ? DateTime.tryParse(
              json['facebook_created_time'].toString(),
            )?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
      isHidden: json['is_hidden'] ?? false,
      isLiveCommerce: json['is_live_commerce'] ?? false,
      comments: json.containsKey('comments') && json['comments'] is List
          ? (json['comments'] as List)
                .map(
                  (comment) => FacebookComment.fromJson(
                    Map<String, dynamic>.from(comment),
                  ),
                )
                .toList()
          : [],
    );
  }

  String get formattedDate {
    final time = facebookCreatedTime ?? createdAt;
    if (time == null) return 'Date inconnue';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} j';

    return '${time.day}/${time.month}/${time.year} à ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get truncatedMessage {
    if (message == null || message!.isEmpty) return 'Pas de message';
    return message!.length > 100
        ? '${message!.substring(0, 100)}...'
        : message!;
  }
}

class FacebookLiveVideo {
  final String id;
  final String facebookVideoId;
  final String pageId;
  final String? title;
  final String? description;
  final String status;
  final DateTime? scheduledStartTime;
  final DateTime? actualStartTime;
  final DateTime? endTime;
  final int viewersCount;
  final int totalComments;
  final int totalOrders;
  final double totalRevenue;
  final int nlpProcessedComments;
  final int ambiguousComments;
  final bool autoProcessComments;
  final bool notifyOnNewOrders;
  final String sellerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? streamUrl;
  final String? permalinkUrl;
  final int? duration;
  final List<FacebookComment> comments;

  FacebookLiveVideo({
    required this.id,
    required this.facebookVideoId,
    required this.pageId,
    this.title,
    this.description,
    required this.status,
    this.scheduledStartTime,
    this.actualStartTime,
    this.endTime,
    this.viewersCount = 0,
    this.totalComments = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.nlpProcessedComments = 0,
    this.ambiguousComments = 0,
    required this.autoProcessComments,
    required this.notifyOnNewOrders,
    required this.sellerId,
    this.createdAt,
    this.updatedAt,
    this.streamUrl,
    this.permalinkUrl,
    this.duration,
    this.comments = const [],
  });

  factory FacebookLiveVideo.fromJson(Map<String, dynamic> json) {
    return FacebookLiveVideo(
      id: json['id']?.toString() ?? '',
      facebookVideoId:
          json['facebook_video_id']?.toString() ?? json['id']?.toString() ?? '',
      pageId: json['page_id']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'published',
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.tryParse(
              json['scheduled_start_time'].toString(),
            )?.toLocal()
          : null,
      actualStartTime: json['actual_start_time'] != null
          ? DateTime.tryParse(json['actual_start_time'].toString())?.toLocal()
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())?.toLocal()
          : null,
      viewersCount: (json['viewers_count'] ?? 0) as int,
      totalComments: (json['total_comments'] ?? 0) as int,
      totalOrders: (json['total_orders'] ?? 0) as int,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      nlpProcessedComments: (json['nlp_processed_comments'] ?? 0) as int,
      ambiguousComments: (json['ambiguous_comments'] ?? 0) as int,
      autoProcessComments: json['auto_process_comments'] ?? false,
      notifyOnNewOrders: json['notify_on_new_orders'] ?? false,
      sellerId: json['seller_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
      streamUrl: json['stream_url']?.toString(),
      permalinkUrl: json['permalink_url']?.toString(),
      duration: (json['duration'] ?? 0) as int,
      comments: json.containsKey('comments') && json['comments'] is List
          ? (json['comments'] as List)
                .map(
                  (comment) => FacebookComment.fromJson(
                    Map<String, dynamic>.from(comment),
                  ),
                )
                .toList()
          : [],
    );
  }

  String get formattedDate {
    if (status.toLowerCase() == 'live') return 'EN DIRECT';
    if (actualStartTime != null) {
      return '${actualStartTime!.day}/${actualStartTime!.month} ${actualStartTime!.hour}:${actualStartTime!.minute.toString().padLeft(2, '0')}';
    }
    if (scheduledStartTime != null) {
      return 'Planifié: ${scheduledStartTime!.day}/${scheduledStartTime!.month}';
    }
    return 'Publié';
  }

  bool get isLive => status.toLowerCase() == 'live';
  bool get isEnded => status.toLowerCase() == 'ended';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isPublished => status.toLowerCase() == 'published';
}

class FacebookComment {
  final String id;
  final String message;
  final String? userId;
  final String? userName;
  final String? pageId;
  final String? intent;
  final String? sentiment;
  final Map<String, dynamic>? entities;
  final String? priority;
  final String sellerId;
  final String? postId;
  final String status;
  final String? detectedCodeArticle;
  final String? detectedProductName;
  final int detectedQuantity;
  final double? confidenceScore;
  final String? responseText;
  final String? actionTaken;
  final Map<String, dynamic>? extractedData;
  final Map<String, dynamic>? validationData;
  final String? orderId;
  final DateTime? facebookCreatedTime;
  final int? processingTimeMs;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FacebookComment({
    required this.id,
    required this.message,
    this.userId,
    this.userName,
    this.pageId,
    this.intent,
    this.sentiment,
    this.entities,
    this.priority,
    required this.sellerId,
    this.postId,
    required this.status,
    this.detectedCodeArticle,
    this.detectedProductName,
    required this.detectedQuantity,
    this.confidenceScore,
    this.responseText,
    this.actionTaken,
    this.extractedData,
    this.validationData,
    this.orderId,
    this.facebookCreatedTime,
    this.processingTimeMs,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory FacebookComment.fromJson(Map<String, dynamic> json) {
    // CORRECTION : Gérer la conversion sécurisée des nombres
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.tryParse(value) ?? 0;
        } catch (_) {
          return 0;
        }
      }
      return 0;
    }

    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.tryParse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return FacebookComment(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      userName: json['user_name']?.toString(),
      pageId: json['page_id']?.toString(),
      intent: json['intent']?.toString(),
      sentiment: json['sentiment']?.toString(),
      entities: json['entities'] != null
          ? Map<String, dynamic>.from(json['entities'])
          : null,
      priority: json['priority']?.toString(),
      sellerId: json['seller_id']?.toString() ?? '',
      postId: json['post_id']?.toString(),
      status: json['status']?.toString() ?? 'new',
      detectedCodeArticle: json['detected_code_article']?.toString(),
      detectedProductName: json['detected_product_name']?.toString(),
      detectedQuantity: safeInt(json['detected_quantity']),
      confidenceScore: safeDouble(json['confidence_score']),
      responseText: json['response_text']?.toString(),
      actionTaken: json['action_taken']?.toString(),
      extractedData: json['extracted_data'] != null
          ? Map<String, dynamic>.from(json['extracted_data'])
          : null,
      validationData: json['validation_data'] != null
          ? Map<String, dynamic>.from(json['validation_data'])
          : null,
      orderId: json['order_id']?.toString(),
      facebookCreatedTime: json['facebook_created_time'] != null
          ? DateTime.tryParse(
              json['facebook_created_time'].toString(),
            )?.toLocal()
          : null,
      processingTimeMs: json['processing_time_ms'] != null
          ? safeInt(json['processing_time_ms'])
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }

  String get formattedTime {
    final time = facebookCreatedTime ?? createdAt;
    if (time == null) return 'Date inconnue';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    if (difference.inDays < 30) return 'Il y a ${difference.inDays} j';

    return '${time.day}/${time.month}/${time.year}';
  }

  bool get hasProductDetection =>
      detectedCodeArticle != null && detectedCodeArticle!.isNotEmpty;
  bool get isProcessed => status == 'processed' || status == 'replied';
  bool get isNew => status == 'new';
  bool get requiresAttention => status == 'new' && priority == 'high';
}

class FacebookMessage {
  final String id;
  final String? customerFacebookId;
  final String messageType;
  final String content;
  final String status;
  final String direction;
  final String? facebookPageId;
  final String sellerId;
  final String? orderId;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final String? messageId;
  final String? senderId;
  final String? recipientId;
  final Map<String, dynamic>? messageMetadata;

  FacebookMessage({
    required this.id,
    this.customerFacebookId,
    required this.messageType,
    required this.content,
    required this.status,
    required this.direction,
    this.facebookPageId,
    required this.sellerId,
    this.orderId,
    this.sentAt,
    this.createdAt,
    this.messageId,
    this.senderId,
    this.recipientId,
    this.messageMetadata,
  });

  factory FacebookMessage.fromJson(Map<String, dynamic> json) {
    return FacebookMessage(
      id: json['id']?.toString() ?? '',
      customerFacebookId: json['customer_facebook_id']?.toString(),
      messageType: json['message_type']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      direction: json['direction']?.toString() ?? 'outgoing',
      facebookPageId: json['facebook_page_id']?.toString(),
      sellerId: json['seller_id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      messageId: json['message_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      recipientId: json['recipient_id']?.toString(),
      messageMetadata: json['message_metadata'] != null
          ? Map<String, dynamic>.from(json['message_metadata'])
          : null,
    );
  }

  bool get isIncoming => direction == 'incoming';
  bool get isOutgoing => direction == 'outgoing';
  bool get isDelivered => status == 'delivered';
  bool get isRead => status == 'read';
}

// ==================== MODÈLES SUPPORT ====================

class FacebookWebhookLog {
  final String id;
  final String objectType;
  final String eventType;
  final String? entryId;
  final String? pageId;
  final Map<String, dynamic> payload;
  final String? signature;
  final String httpMethod;
  final int? statusCode;
  final bool processed;
  final String? processingError;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FacebookWebhookLog({
    required this.id,
    required this.objectType,
    required this.eventType,
    this.entryId,
    this.pageId,
    required this.payload,
    this.signature,
    required this.httpMethod,
    this.statusCode,
    required this.processed,
    this.processingError,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory FacebookWebhookLog.fromJson(Map<String, dynamic> json) {
    return FacebookWebhookLog(
      id: json['id']?.toString() ?? '',
      objectType: json['object_type']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? '',
      entryId: json['entry_id']?.toString(),
      pageId: json['page_id']?.toString(),
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      signature: json['signature']?.toString(),
      httpMethod: json['http_method']?.toString() ?? 'POST',
      statusCode: json['status_code'] != null
          ? int.tryParse(json['status_code'].toString())
          : null,
      processed: json['processed'] ?? false,
      processingError: json['processing_error']?.toString(),
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }
}

class FacebookWebhookSubscription {
  final String id;
  final String pageId;
  final String subscriptionType;
  final bool isActive;
  final DateTime? lastReceived;
  final String sellerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FacebookWebhookSubscription({
    required this.id,
    required this.pageId,
    required this.subscriptionType,
    required this.isActive,
    this.lastReceived,
    required this.sellerId,
    this.createdAt,
    this.updatedAt,
  });

  factory FacebookWebhookSubscription.fromJson(Map<String, dynamic> json) {
    return FacebookWebhookSubscription(
      id: json['id']?.toString() ?? '',
      pageId: json['page_id']?.toString() ?? '',
      subscriptionType: json['subscription_type']?.toString() ?? 'webhook',
      isActive: json['is_active'] ?? true,
      lastReceived: json['last_received'] != null
          ? DateTime.tryParse(json['last_received'].toString())?.toLocal()
          : null,
      sellerId: json['seller_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }
}

class NLPProcessingLog {
  final String id;
  final String commentId;
  final String processorVersion;
  final int? processingTimeMs;
  final bool success;
  final String? detectedIntent;
  final double? confidenceScore;
  final bool? isAmbiguous;
  final bool? requiresHumanReview;
  final List<dynamic>? detectedProducts;
  final List<dynamic>? detectedQuantities;
  final List<dynamic>? detectedColors;
  final List<dynamic>? detectedSizes;
  final String? errorMessage;
  final Map<String, dynamic>? errorDetails;
  final String? stackTrace;
  final DateTime? createdAt;

  NLPProcessingLog({
    required this.id,
    required this.commentId,
    required this.processorVersion,
    this.processingTimeMs,
    required this.success,
    this.detectedIntent,
    this.confidenceScore,
    this.isAmbiguous,
    this.requiresHumanReview,
    this.detectedProducts,
    this.detectedQuantities,
    this.detectedColors,
    this.detectedSizes,
    this.errorMessage,
    this.errorDetails,
    this.stackTrace,
    this.createdAt,
  });

  factory NLPProcessingLog.fromJson(Map<String, dynamic> json) {
    return NLPProcessingLog(
      id: json['id']?.toString() ?? '',
      commentId: json['comment_id']?.toString() ?? '',
      processorVersion: json['processor_version']?.toString() ?? '1.0.0',
      processingTimeMs: json['processing_time_ms'] != null
          ? int.tryParse(json['processing_time_ms'].toString())
          : null,
      success: json['success'] ?? true,
      detectedIntent: json['detected_intent']?.toString(),
      confidenceScore: json['confidence_score'] != null
          ? (json['confidence_score'] is double
                ? json['confidence_score'] as double
                : double.tryParse(json['confidence_score'].toString()) ?? 0.0)
          : 0.0,
      isAmbiguous: json['is_ambiguous'],
      requiresHumanReview: json['requires_human_review'],
      detectedProducts: json['detected_products'] != null
          ? List<dynamic>.from(json['detected_products'])
          : null,
      detectedQuantities: json['detected_quantities'] != null
          ? List<dynamic>.from(json['detected_quantities'])
          : null,
      detectedColors: json['detected_colors'] != null
          ? List<dynamic>.from(json['detected_colors'])
          : null,
      detectedSizes: json['detected_sizes'] != null
          ? List<dynamic>.from(json['detected_sizes'])
          : null,
      errorMessage: json['error_message']?.toString(),
      errorDetails: json['error_details'] != null
          ? Map<String, dynamic>.from(json['error_details'])
          : null,
      stackTrace: json['stack_trace']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
    );
  }
}

// ==================== RESPONSE MODELS ====================

class FacebookConnectResponse {
  final bool success;
  final String authUrl;
  final String? state;

  FacebookConnectResponse({
    required this.success,
    required this.authUrl,
    this.state,
  });

  factory FacebookConnectResponse.fromJson(Map<String, dynamic> json) {
    return FacebookConnectResponse(
      success: json['success'] ?? false,
      authUrl: json['auth_url']?.toString() ?? '',
      state: json['state']?.toString(),
    );
  }
}

class FacebookAuthResponse {
  final bool success;
  final String message;
  final FacebookUser? user;
  final List<FacebookPage>? pages;

  FacebookAuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.pages,
  });

  factory FacebookAuthResponse.fromJson(Map<String, dynamic> json) {
    return FacebookAuthResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      user: json['user'] != null ? FacebookUser.fromJson(json['user']) : null,
      pages: json['pages'] != null
          ? (json['pages'] as List)
                .map((page) => FacebookPage.fromJson(page))
                .toList()
          : null,
    );
  }
}

class FacebookPageResponse {
  final String id;
  final String pageId;
  final String name;
  final String? category;
  final int? fanCount;
  final bool isSelected;
  final String? coverPhotoUrl;
  final String? profilePicUrl;
  final String? createdAt;
  final bool? autoReplyEnabled;
  final bool? autoProcessComments;

  FacebookPageResponse({
    required this.id,
    required this.pageId,
    required this.name,
    this.category,
    this.fanCount,
    required this.isSelected,
    this.coverPhotoUrl,
    this.profilePicUrl,
    this.createdAt,
    this.autoReplyEnabled,
    this.autoProcessComments,
  });

  factory FacebookPageResponse.fromJson(Map<String, dynamic> json) {
    return FacebookPageResponse(
      id: json['id']?.toString() ?? '',
      pageId: json['page_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString(),
      fanCount: json['fan_count'] != null
          ? int.tryParse(json['fan_count'].toString())
          : null,
      isSelected: json['is_selected'] ?? false,
      coverPhotoUrl: json['cover_photo_url']?.toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      autoReplyEnabled: json['auto_reply_enabled'],
      autoProcessComments: json['auto_process_comments'],
    );
  }
}

class SelectPageResponse {
  final bool success;
  final String message;
  final FacebookPageResponse page;

  SelectPageResponse({
    required this.success,
    required this.message,
    required this.page,
  });

  factory SelectPageResponse.fromJson(Map<String, dynamic> json) {
    return SelectPageResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      page: FacebookPageResponse.fromJson(json['page']),
    );
  }
}

class SyncRequest {
  final String pageId;
  final bool syncPosts;
  final bool syncComments;
  final bool syncMessages;

  SyncRequest({
    required this.pageId,
    this.syncPosts = true,
    this.syncComments = true,
    this.syncMessages = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'page_id': pageId,
      'sync_posts': syncPosts,
      'sync_comments': syncComments,
      'sync_messages': syncMessages,
    };
  }
}

class CommentResponse {
  final String commentId;
  final String message;
  final String? authorName;
  final String pageId;
  final String? postId;
  final DateTime? createdTime;
  final String? sentiment;
  final String? responseStatus;

  CommentResponse({
    required this.commentId,
    required this.message,
    this.authorName,
    required this.pageId,
    this.postId,
    this.createdTime,
    this.sentiment,
    this.responseStatus,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      commentId: json['comment_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      authorName: json['author_name']?.toString(),
      pageId: json['page_id']?.toString() ?? '',
      postId: json['post_id']?.toString(),
      createdTime: json['created_time'] != null
          ? DateTime.tryParse(json['created_time'].toString())?.toLocal()
          : null,
      sentiment: json['sentiment']?.toString(),
      responseStatus: json['response_status']?.toString() ?? 'pending',
    );
  }
}

class ReplyRequest {
  final String message;
  final String? replyToCommentId;
  final bool isPrivate;

  ReplyRequest({
    required this.message,
    this.replyToCommentId,
    this.isPrivate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reply_to_comment_id': replyToCommentId,
      'is_private': isPrivate,
    };
  }
}

// ==================== NOUVEAUX MODÈLES D'API ====================

class FacebookReplyHistory {
  final String id;
  final String commentId;
  final String orderId;
  final String message;
  final String? facebookResponseId;
  final DateTime sentAt;

  FacebookReplyHistory({
    required this.id,
    required this.commentId,
    required this.orderId,
    required this.message,
    this.facebookResponseId,
    required this.sentAt,
  });

  factory FacebookReplyHistory.fromJson(Map<String, dynamic> json) {
    return FacebookReplyHistory(
      id: json['id']?.toString() ?? '',
      commentId: json['comment_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      facebookResponseId: json['facebook_response_id']?.toString(),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class MessengerMessage {
  final String id;
  final String messageType;
  final String senderId;
  final String recipientId;
  final String? facebookMessageId;
  final String messageContent;
  final Map<String, dynamic>? quickReplies;
  final Map<String, dynamic>? attachments;
  final String? orderId;
  final String? commentId;
  final String sellerId;
  final String status;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final String platform;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessengerMessage({
    required this.id,
    required this.messageType,
    required this.senderId,
    required this.recipientId,
    this.facebookMessageId,
    required this.messageContent,
    this.quickReplies,
    this.attachments,
    this.orderId,
    this.commentId,
    required this.sellerId,
    required this.status,
    this.errorMessage,
    this.metadata,
    this.platform = 'facebook_messenger',
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessengerMessage.fromJson(Map<String, dynamic> json) {
    return MessengerMessage(
      id: json['id']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? '',
      facebookMessageId: json['facebook_message_id']?.toString(),
      messageContent: json['message_content']?.toString() ?? '',
      quickReplies: json['quick_replies'] != null
          ? Map<String, dynamic>.from(json['quick_replies'])
          : null,
      attachments: json['attachments'] != null
          ? Map<String, dynamic>.from(json['attachments'])
          : null,
      orderId: json['order_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      sellerId: json['seller_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'sent',
      errorMessage: json['error_message']?.toString(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      platform: json['platform']?.toString() ?? 'facebook_messenger',
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isDelivered => status == 'delivered';
  bool get isRead => status == 'read';
  bool get isFailed => status == 'failed';
}

class FacebookMessageTemplate {
  final String id;
  final String templateType;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  FacebookMessageTemplate({
    required this.id,
    required this.templateType,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FacebookMessageTemplate.fromJson(Map<String, dynamic> json) {
    return FacebookMessageTemplate(
      id: json['id']?.toString() ?? '',
      templateType: json['template_type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ==================== UTILITY CLASSES ====================

enum LiveStatus { live, ended, scheduled, processing }

extension LiveStatusExtension on LiveStatus {
  String get displayName {
    switch (this) {
      case LiveStatus.live:
        return 'EN DIRECT';
      case LiveStatus.ended:
        return 'TERMINÉ';
      case LiveStatus.scheduled:
        return 'PLANIFIÉ';
      case LiveStatus.processing:
        return 'EN TRAITEMENT';
    }
  }

  String get backendValue {
    switch (this) {
      case LiveStatus.live:
        return 'live';
      case LiveStatus.ended:
        return 'ended';
      case LiveStatus.scheduled:
        return 'scheduled';
      case LiveStatus.processing:
        return 'processing';
    }
  }
}

enum CommentStatus { newComment, processed, replied, deleted }

extension CommentStatusExtension on CommentStatus {
  String get displayName {
    switch (this) {
      case CommentStatus.newComment:
        return 'Nouveau';
      case CommentStatus.processed:
        return 'Traité';
      case CommentStatus.replied:
        return 'Répondu';
      case CommentStatus.deleted:
        return 'Supprimé';
    }
  }

  String get backendValue {
    switch (this) {
      case CommentStatus.newComment:
        return 'new';
      case CommentStatus.processed:
        return 'processed';
      case CommentStatus.replied:
        return 'replied';
      case CommentStatus.deleted:
        return 'deleted';
    }
  }
}

enum MessageDirection { incoming, outgoing }

extension MessageDirectionExtension on MessageDirection {
  String get backendValue {
    switch (this) {
      case MessageDirection.incoming:
        return 'incoming';
      case MessageDirection.outgoing:
        return 'outgoing';
    }
  }
}

// ==================== FILTER MODELS ====================

class FacebookFilterOptions {
  final String? pageId;
  final CommentStatus? status;
  final String? intent;
  final String? sentiment;
  final int limit;
  final int offset;

  FacebookFilterOptions({
    this.pageId,
    this.status,
    this.intent,
    this.sentiment,
    this.limit = 50,
    this.offset = 0,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};

    if (pageId != null) params['page_id'] = pageId;
    if (status != null) params['status'] = status!.backendValue;
    if (intent != null) params['intent'] = intent;
    if (sentiment != null) params['sentiment'] = sentiment;

    return params;
  }
}
