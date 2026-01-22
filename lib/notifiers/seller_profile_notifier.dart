// lib/notifiers/seller_profile_notifier.dart
import 'package:flutter/material.dart';

class SellerProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String companyName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> facebookInfo;
  String? profileImageUrl;
  String? bio;
  String? website;
  String? subscriptionLevel;
  String? statusLabel;
  Color? statusColor;

  SellerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.companyName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.facebookInfo,
    this.profileImageUrl,
    this.bio,
    this.website,
    this.subscriptionLevel = 'basic',
    this.statusLabel = 'Actif',
    this.statusColor = Colors.green,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['telephone'] ?? '',
      address: json['address'] ?? json['adresse'] ?? '',
      companyName: json['company_name'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      facebookInfo: json['facebook_info'] ?? {},
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
      website: json['website'],
      subscriptionLevel: json['subscription_level'] ?? 'basic',
      statusLabel: json['status_label'] ?? 'Actif',
      statusColor: json['status_color'] != null
          ? Color(int.parse(json['status_color']))
          : Colors.green,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'company_name': companyName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'facebook_info': facebookInfo,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'website': website,
      'subscription_level': subscriptionLevel,
      'status_label': statusLabel,
      'status_color': statusColor?.value.toString(),
    };
  }

  SellerProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? companyName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? facebookInfo,
    String? profileImageUrl,
    String? bio,
    String? website,
    String? subscriptionLevel,
    String? statusLabel,
    Color? statusColor,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      facebookInfo: facebookInfo ?? this.facebookInfo,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      subscriptionLevel: subscriptionLevel ?? this.subscriptionLevel,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

class SellerProfileNotifier extends ChangeNotifier {
  SellerProfile _profile;

  SellerProfileNotifier(this._profile);

  SellerProfile get profile => _profile;

  void updateProfile(SellerProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  void updateProfileImage(String imageUrl) {
    _profile = _profile.copyWith(profileImageUrl: imageUrl);
    notifyListeners();
  }

  void updateBasicInfo({
    String? fullName,
    String? phone,
    String? address,
    String? companyName,
    String? bio,
    String? website,
  }) {
    _profile = _profile.copyWith(
      fullName: fullName,
      phone: phone,
      address: address,
      companyName: companyName,
      bio: bio,
      website: website,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateSubscription(String level) {
    _profile = _profile.copyWith(
      subscriptionLevel: level,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateStatus(String label, Color color) {
    _profile = _profile.copyWith(
      statusLabel: label,
      statusColor: color,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateFacebookInfo(Map<String, dynamic> facebookInfo) {
    _profile = _profile.copyWith(
      facebookInfo: facebookInfo,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void clearProfileImage() {
    _profile = _profile.copyWith(profileImageUrl: null);
    notifyListeners();
  }
}
