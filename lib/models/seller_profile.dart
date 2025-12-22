import 'package:flutter/material.dart';

class Subscription {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final Color color;

  const Subscription({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.color,
  });

  // Couleurs spécifiques selon le type d'abonnement
  static Color getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'basic':
        return const Color(0xFFFFB300); // Jaune/or
      case 'comfort':
      case 'business':
        return const Color(0xFF2196F3); // Bleu
      case 'premium':
        return const Color(0xFFF44336); // Rouge/orangé
      default:
        return const Color(0xFF2196F3);
    }
  }

  factory Subscription.defaultSubscription() {
    return Subscription(
      id: '1',
      type: 'Basic',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      status: 'Actif',
      color: getColorForType('Basic'),
    );
  }
}

class FacebookInfo {
  final String pageName;
  final String pageUrl;
  final String tokenStatus;
  final DateTime tokenExpiry;

  const FacebookInfo({
    required this.pageName,
    required this.pageUrl,
    required this.tokenStatus,
    required this.tokenExpiry,
  });

  factory FacebookInfo.defaultInfo() {
    return FacebookInfo(
      pageName: 'Ma Boutique Live',
      pageUrl: 'facebook.com/maboutiquelive',
      tokenStatus: 'Valide',
      tokenExpiry: DateTime.now().add(const Duration(days: 60)),
    );
  }
}

class SellerProfile {
  final String id;
  final String fullName;
  final String companyName;
  final String email;
  final String phone;
  final String address;
  final String? profileImageUrl;
  final String status;
  final DateTime createdAt;
  final Subscription subscription;
  final FacebookInfo facebookInfo;

  const SellerProfile({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImageUrl,
    required this.status,
    required this.createdAt,
    required this.subscription,
    required this.facebookInfo,
  });

  // Méthode pour obtenir la couleur du statut
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'suspendu':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Méthode pour obtenir le libellé du statut
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'actif':
        return 'Actif';
      case 'en attente':
        return 'En attente';
      case 'suspendu':
        return 'Suspendu';
      default:
        return 'Inconnu';
    }
  }

  // Factory pour créer un profil par défaut
  factory SellerProfile.defaultProfile() {
    return SellerProfile(
      id: '1',
      fullName: 'Jean Dupont',
      companyName: 'Boutique Fashion Live',
      email: 'jean.dupont@example.com',
      phone: '+33 6 12 34 56 78',
      address: '123 Rue du Commerce, 75001 Paris',
      profileImageUrl: null,
      status: 'Actif',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      subscription: Subscription.defaultSubscription(),
      facebookInfo: FacebookInfo.defaultInfo(),
    );
  }

  // Méthode pour convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'subscription': {
        'id': subscription.id,
        'type': subscription.type,
        'startDate': subscription.startDate.toIso8601String(),
        'endDate': subscription.endDate.toIso8601String(),
        'status': subscription.status,
      },
      'facebookInfo': {
        'pageName': facebookInfo.pageName,
        'pageUrl': facebookInfo.pageUrl,
        'tokenStatus': facebookInfo.tokenStatus,
        'tokenExpiry': facebookInfo.tokenExpiry.toIso8601String(),
      },
    };
  }

  // Factory pour créer à partir d'un Map
  factory SellerProfile.fromMap(Map<String, dynamic> map) {
    return SellerProfile(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      companyName: map['companyName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      subscription: Subscription(
        id: (map['subscription'] as Map)['id'] as String,
        type: (map['subscription'] as Map)['type'] as String,
        startDate: DateTime.parse(
          (map['subscription'] as Map)['startDate'] as String,
        ),
        endDate: DateTime.parse(
          (map['subscription'] as Map)['endDate'] as String,
        ),
        status: (map['subscription'] as Map)['status'] as String,
        color: Subscription.getColorForType(
          (map['subscription'] as Map)['type'] as String,
        ),
      ),
      facebookInfo: FacebookInfo(
        pageName: (map['facebookInfo'] as Map)['pageName'] as String,
        pageUrl: (map['facebookInfo'] as Map)['pageUrl'] as String,
        tokenStatus: (map['facebookInfo'] as Map)['tokenStatus'] as String,
        tokenExpiry: DateTime.parse(
          (map['facebookInfo'] as Map)['tokenExpiry'] as String,
        ),
      ),
    );
  }
}
