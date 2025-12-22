class Vendor {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Champs spécifiques au vendeur
  final String? sellerId;
  final String? companyName;
  final String? subscriptionStatus;

  Vendor({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sellerId,
    this.companyName,
    this.subscriptionStatus,
  });

  // Factory constructor pour créer un Vendor depuis JSON
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      role: json['role'] ?? '',
      phone: json['telephone'] ?? json['phone'] ?? '',
      address: json['adresse'] ?? json['address'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      sellerId: json['seller_id']?.toString(),
      companyName: json['company_name'],
      subscriptionStatus: json['abonnement_status'],
    );
  }

  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': name,
      'role': role,
      'telephone': phone,
      'adresse': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (sellerId != null) 'seller_id': sellerId,
      if (companyName != null) 'company_name': companyName,
      if (subscriptionStatus != null) 'abonnement_status': subscriptionStatus,
    };
  }

  // Méthode pour créer une copie avec modifications
  Vendor copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerId,
    String? companyName,
    String? subscriptionStatus,
  }) {
    return Vendor(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerId: sellerId ?? this.sellerId,
      companyName: companyName ?? this.companyName,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }

  @override
  String toString() {
    return 'Vendor(id: $id, email: $email, name: $name, role: $role, sellerId: $sellerId, companyName: $companyName, subscriptionStatus: $subscriptionStatus)';
  }
}
