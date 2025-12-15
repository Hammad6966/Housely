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

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.hostName,
    required this.hostAvatar,
    required this.amenities,
    required this.bedrooms,
    required this.bathrooms,
    required this.guests,
    this.isFavorite = false,
    required this.propertyType,
    required this.latitude,
    required this.longitude,
  });

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
    );
  }
}
