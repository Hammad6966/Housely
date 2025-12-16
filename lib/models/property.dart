class Property {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String hostName;
  final String hostAvatar;
  final List<String> amenities;
  final int bedrooms;
  final int bathrooms;
  final int guests;
  final bool isFavorite;
  final String propertyType;
  final double latitude;
  final double longitude;
  final String? ownerId;
  final String listingType; // 'For Rent' or 'For Sale'
  final int sqft;
  final DateTime? createdAt;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.images,
    required this.hostName,
    required this.hostAvatar,
    required this.amenities,
    required this.bedrooms,
    required this.bathrooms,
    this.guests = 1,
    this.isFavorite = false,
    required this.propertyType,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.ownerId,
    this.listingType = 'For Rent',
    this.sqft = 0,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'amenities': amenities,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'guests': guests,
      'isFavorite': isFavorite,
      'propertyType': propertyType,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': ownerId,
      'listingType': listingType,
      'sqft': sqft,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      hostName: json['hostName'] ?? '',
      hostAvatar: json['hostAvatar'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      guests: json['guests'] ?? 1,
      isFavorite: json['isFavorite'] ?? false,
      propertyType: json['propertyType'] ?? 'House',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      ownerId: json['ownerId'],
      listingType: json['listingType'] ?? 'For Rent',
      sqft: json['sqft'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    double? price,
    double? rating,
    int? reviewCount,
    List<String>? images,
    String? hostName,
    String? hostAvatar,
    List<String>? amenities,
    int? bedrooms,
    int? bathrooms,
    int? guests,
    bool? isFavorite,
    String? propertyType,
    double? latitude,
    double? longitude,
    String? ownerId,
    String? listingType,
    int? sqft,
    DateTime? createdAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      amenities: amenities ?? this.amenities,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      guests: guests ?? this.guests,
      isFavorite: isFavorite ?? this.isFavorite,
      propertyType: propertyType ?? this.propertyType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      listingType: listingType ?? this.listingType,
      sqft: sqft ?? this.sqft,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
