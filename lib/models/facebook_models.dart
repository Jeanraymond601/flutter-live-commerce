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
      id: json['id'],
      facebookUserId: json['facebook_user_id'],
      email: json['email'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicUrl: json['profile_pic_url'],
      longLivedToken: json['long_lived_token'],
      tokenExpiresAt: DateTime.parse(json['token_expires_at']),
      grantedPermissions: List<String>.from(json['granted_permissions'] ?? []),
      sellerId: json['seller_id'],
      isActive: json['is_active'] ?? true,
      lastSync: json['last_sync'] != null
          ? DateTime.parse(json['last_sync'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
  bool isSelected; // ⬅️ CHANGER DE final À bool
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
    required this.isSelected, // ⬅️ CHANGER EN required
    required this.autoReplyEnabled,
    required this.autoProcessComments,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookPage.fromJson(Map<String, dynamic> json) {
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
      tokenExpiresAt: DateTime.now().add(const Duration(days: 60)),
      facebookUserId: json['facebook_user_id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
      autoReplyEnabled: json['auto_reply_enabled'] == true,
      autoProcessComments: json['auto_process_comments'] ?? false,
      createdAt: DateTime.now(),
      updatedAt: null,
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

  // ⬅️ AJOUTER: Méthode pour créer une copie avec des valeurs modifiées
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
  final String postId;
  final String? message;
  final String? type;
  final String? pictureUrl;
  final String? fullPictureUrl;
  final String? link;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String pageId;
  final String sellerId;
  final DateTime facebookCreatedTime;
  final DateTime? updatedTime;
  final bool isHidden;
  final bool isLiveCommerce;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FacebookPost({
    required this.id,
    required this.postId,
    this.message,
    this.type,
    this.pictureUrl,
    this.fullPictureUrl,
    this.link,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.pageId,
    required this.sellerId,
    required this.facebookCreatedTime,
    this.updatedTime,
    required this.isHidden,
    required this.isLiveCommerce,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookPost.fromJson(Map<String, dynamic> json) {
    return FacebookPost(
      id: json['id'],
      postId: json['post_id'],
      message: json['message'],
      type: json['type'],
      pictureUrl: json['picture_url'],
      fullPictureUrl: json['full_picture_url'],
      link: json['link'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      pageId: json['page_id'],
      sellerId: json['seller_id'],
      facebookCreatedTime: DateTime.parse(json['facebook_created_time']),
      updatedTime: json['updated_time'] != null
          ? DateTime.parse(json['updated_time'])
          : null,
      isHidden: json['is_hidden'] ?? false,
      isLiveCommerce: json['is_live_commerce'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(facebookCreatedTime);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} j';

    return '${facebookCreatedTime.day}/${facebookCreatedTime.month}/${facebookCreatedTime.year}';
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
  final int totalComments;
  final int totalOrders;
  final double totalRevenue;
  final int nlpProcessedComments;
  final int ambiguousComments;
  final bool autoProcessComments;
  final bool notifyOnNewOrders;
  final String sellerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    required this.totalComments,
    required this.totalOrders,
    required this.totalRevenue,
    required this.nlpProcessedComments,
    required this.ambiguousComments,
    required this.autoProcessComments,
    required this.notifyOnNewOrders,
    required this.sellerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookLiveVideo.fromJson(Map<String, dynamic> json) {
    return FacebookLiveVideo(
      id: json['id'],
      facebookVideoId: json['facebook_video_id'],
      pageId: json['page_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'scheduled',
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.parse(json['scheduled_start_time'])
          : null,
      actualStartTime: json['actual_start_time'] != null
          ? DateTime.parse(json['actual_start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      totalComments: json['total_comments'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      nlpProcessedComments: json['nlp_processed_comments'] ?? 0,
      ambiguousComments: json['ambiguous_comments'] ?? 0,
      autoProcessComments: json['auto_process_comments'] ?? true,
      notifyOnNewOrders: json['notify_on_new_orders'] ?? true,
      sellerId: json['seller_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get formattedDate {
    if (status.toLowerCase() == 'live') return 'EN DIRECT';
    if (actualStartTime != null) {
      return '${actualStartTime!.day}/${actualStartTime!.month} ${actualStartTime!.hour}:${actualStartTime!.minute.toString().padLeft(2, '0')}';
    }
    return 'Planifié';
  }

  bool get isLive => status.toLowerCase() == 'live';
  bool get isEnded => status.toLowerCase() == 'ended';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
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
  final DateTime createdAt;
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
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookComment.fromJson(Map<String, dynamic> json) {
    return FacebookComment(
      id: json['id'],
      message: json['message'] ?? '',
      userId: json['user_id'],
      userName: json['user_name'],
      pageId: json['page_id'],
      intent: json['intent'],
      sentiment: json['sentiment'],
      entities: json['entities'] != null
          ? Map<String, dynamic>.from(json['entities'])
          : null,
      priority: json['priority'],
      sellerId: json['seller_id'],
      postId: json['post_id'],
      status: json['status'] ?? 'new',
      detectedCodeArticle: json['detected_code_article'],
      detectedProductName: json['detected_product_name'],
      detectedQuantity: json['detected_quantity'] ?? 1,
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      responseText: json['response_text'],
      actionTaken: json['action_taken'],
      extractedData: json['extracted_data'] != null
          ? Map<String, dynamic>.from(json['extracted_data'])
          : null,
      validationData: json['validation_data'] != null
          ? Map<String, dynamic>.from(json['validation_data'])
          : null,
      orderId: json['order_id'],
      facebookCreatedTime: json['facebook_created_time'] != null
          ? DateTime.parse(json['facebook_created_time'])
          : null,
      processingTimeMs: json['processing_time_ms'],
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get formattedTime {
    final time = facebookCreatedTime ?? createdAt;
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
  final DateTime createdAt;

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
    required this.createdAt,
  });

  factory FacebookMessage.fromJson(Map<String, dynamic> json) {
    return FacebookMessage(
      id: json['id'],
      customerFacebookId: json['customer_facebook_id'],
      messageType: json['message_type'],
      content: json['content'],
      status: json['status'] ?? 'pending',
      direction: json['direction'] ?? 'outgoing',
      facebookPageId: json['facebook_page_id'],
      sellerId: json['seller_id'],
      orderId: json['order_id'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
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
  final DateTime createdAt;
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
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookWebhookLog.fromJson(Map<String, dynamic> json) {
    return FacebookWebhookLog(
      id: json['id'],
      objectType: json['object_type'],
      eventType: json['event_type'],
      entryId: json['entry_id'],
      pageId: json['page_id'],
      payload: Map<String, dynamic>.from(json['payload']),
      signature: json['signature'],
      httpMethod: json['http_method'] ?? 'POST',
      statusCode: json['status_code'],
      processed: json['processed'] ?? false,
      processingError: json['processing_error'],
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
  final DateTime createdAt;
  final DateTime? updatedAt;

  FacebookWebhookSubscription({
    required this.id,
    required this.pageId,
    required this.subscriptionType,
    required this.isActive,
    this.lastReceived,
    required this.sellerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory FacebookWebhookSubscription.fromJson(Map<String, dynamic> json) {
    return FacebookWebhookSubscription(
      id: json['id'],
      pageId: json['page_id'],
      subscriptionType: json['subscription_type'],
      isActive: json['is_active'] ?? true,
      lastReceived: json['last_received'] != null
          ? DateTime.parse(json['last_received'])
          : null,
      sellerId: json['seller_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
  final DateTime createdAt;

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
    required this.createdAt,
  });

  factory NLPProcessingLog.fromJson(Map<String, dynamic> json) {
    return NLPProcessingLog(
      id: json['id'],
      commentId: json['comment_id'],
      processorVersion: json['processor_version'] ?? '1.0.0',
      processingTimeMs: json['processing_time_ms'],
      success: json['success'] ?? true,
      detectedIntent: json['detected_intent'],
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      isAmbiguous: json['is_ambiguous'],
      requiresHumanReview: json['requires_human_review'],
      detectedProducts: json['detected_products'],
      detectedQuantities: json['detected_quantities'],
      detectedColors: json['detected_colors'],
      detectedSizes: json['detected_sizes'],
      errorMessage: json['error_message'],
      errorDetails: json['error_details'] != null
          ? Map<String, dynamic>.from(json['error_details'])
          : null,
      stackTrace: json['stack_trace'],
      createdAt: DateTime.parse(json['created_at']),
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
      authUrl: json['auth_url'],
      state: json['state'],
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
      message: json['message'],
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
  });

  factory FacebookPageResponse.fromJson(Map<String, dynamic> json) {
    return FacebookPageResponse(
      id: json['id'],
      pageId: json['page_id'],
      name: json['name'],
      category: json['category'],
      fanCount: json['fan_count'],
      isSelected: json['is_selected'] ?? false,
      coverPhotoUrl: json['cover_photo_url'],
      profilePicUrl: json['profile_pic_url'],
      createdAt: json['created_at'],
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
      message: json['message'],
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
      commentId: json['comment_id'],
      message: json['message'],
      authorName: json['author_name'],
      pageId: json['page_id'],
      postId: json['post_id'],
      createdTime: json['created_time'] != null
          ? DateTime.parse(json['created_time'])
          : null,
      sentiment: json['sentiment'],
      responseStatus: json['response_status'] ?? 'pending',
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
