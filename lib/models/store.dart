class StoreModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String? logo;
  final String? banner;
  final SocialLinks? socialLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    this.logo,
    this.banner,
    this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id'] ?? json['id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'],
      banner: json['banner'],
      socialLinks: json['socialLinks'] != null 
          ? SocialLinks.fromJson(json['socialLinks']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      if (logo != null) 'logo': logo,
      if (banner != null) 'banner': banner,
      if (socialLinks != null) 'socialLinks': socialLinks!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StoreModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? logo,
    String? banner,
    SocialLinks? socialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SocialLinks {
  final String? facebook;
  final String? instagram;
  final String? website;

  SocialLinks({
    this.facebook,
    this.instagram,
    this.website,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      facebook: json['facebook'],
      instagram: json['instagram'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
      if (website != null) 'website': website,
    };
  }

  SocialLinks copyWith({
    String? facebook,
    String? instagram,
    String? website,
  }) {
    return SocialLinks(
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
    );
  }
}