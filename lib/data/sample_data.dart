import '../models/property.dart';

class SampleData {
  static final List<Property> properties = [
    Property(
      id: '1',
      title: 'Modern Beach House',
      description:
          'Stunning beachfront property with panoramic ocean views. Perfect for a relaxing getaway with family and friends.',
      location: 'Malibu, California',
      price: 450.0,
      rating: 4.9,
      reviewCount: 127,
      images: [
        'assets/images/properties/property1_2.jpg',
        'assets/images/properties/property1_3.jpg',
        'assets/images/properties/property1_4.jpg',
      ],
      hostName: 'Sarah Johnson',
      hostAvatar:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
      amenities: [
        'WiFi',
        'Pool',
        'Parking',
        'Kitchen',
        'Beach Access',
        'Air Conditioning'
      ],
      bedrooms: 3,
      bathrooms: 2,
      guests: 6,
      propertyType: 'House',
      latitude: 34.0259,
      longitude: -118.7798,
    ),
    Property(
      id: '2',
      title: 'Cozy Mountain Cabin',
      description:
          'Rustic cabin nestled in the mountains with breathtaking views. Ideal for nature lovers and outdoor enthusiasts.',
      location: 'Aspen, Colorado',
      price: 320.0,
      rating: 4.7,
      reviewCount: 89,
      images: [
        'assets/images/properties/property2_1.jpg',
        'assets/images/properties/property2_2.jpg',
        'assets/images/properties/property2_3.jpg',
      ],
      hostName: 'Mike Chen',
      hostAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      amenities: [
        'WiFi',
        'Fireplace',
        'Parking',
        'Kitchen',
        'Hiking Trails',
        'Hot Tub'
      ],
      bedrooms: 2,
      bathrooms: 1,
      guests: 4,
      propertyType: 'Cabin',
      latitude: 39.1911,
      longitude: -106.8175,
    ),
    Property(
      id: '3',
      title: 'Luxury City Apartment',
      description:
          'Elegant apartment in the heart of the city with modern amenities and stunning skyline views.',
      location: 'New York, NY',
      price: 280.0,
      rating: 4.8,
      reviewCount: 156,
      images: [
        'assets/images/properties/property3_1.jpg',
        'assets/images/properties/property3_2.jpg',
        'assets/images/properties/property3_3.jpg',
      ],
      hostName: 'Emma Rodriguez',
      hostAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      amenities: [
        'WiFi',
        'Gym',
        'Concierge',
        'Kitchen',
        'City Views',
        'Air Conditioning'
      ],
      bedrooms: 1,
      bathrooms: 1,
      guests: 2,
      propertyType: 'Apartment',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    Property(
      id: '4',
      title: 'Tropical Villa Paradise',
      description:
          'Exotic villa surrounded by lush tropical gardens with private pool and beach access.',
      location: 'Bali, Indonesia',
      price: 180.0,
      rating: 4.9,
      reviewCount: 203,
      images: [
        'assets/images/properties/property4_1.jpg',
        'assets/images/properties/property4_2.jpg',
        'assets/images/properties/property4_3.jpg',
      ],
      hostName: 'Ayu Putri',
      hostAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      amenities: [
        'WiFi',
        'Pool',
        'Beach Access',
        'Kitchen',
        'Garden',
        'Air Conditioning'
      ],
      bedrooms: 4,
      bathrooms: 3,
      guests: 8,
      propertyType: 'Villa',
      latitude: -8.3405,
      longitude: 115.0920,
    ),
    Property(
      id: '5',
      title: 'Charming Countryside Cottage',
      description:
          'Quaint cottage in the English countryside with traditional charm and modern comforts.',
      location: 'Cotswolds, UK',
      price: 220.0,
      rating: 4.6,
      reviewCount: 94,
      images: [
        'assets/images/properties/property2_1.jpg',
        'assets/images/properties/property2_2.jpg',
        'assets/images/properties/property2_3.jpg',
      ],
      hostName: 'James Wilson',
      hostAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      amenities: [
        'WiFi',
        'Fireplace',
        'Garden',
        'Kitchen',
        'Parking',
        'Countryside Views'
      ],
      bedrooms: 2,
      bathrooms: 1,
      guests: 4,
      propertyType: 'Cottage',
      latitude: 51.7520,
      longitude: -1.2577,
    ),
    Property(
      id: '6',
      title: 'Minimalist Studio Loft',
      description:
          'Contemporary studio loft with clean lines and modern design in the arts district.',
      location: 'Los Angeles, CA',
      price: 150.0,
      rating: 4.5,
      reviewCount: 67,
      images: [
        'assets/images/properties/property3_1.jpg',
        'assets/images/properties/property3_2.jpg',
      ],
      hostName: 'Alex Kim',
      hostAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      amenities: [
        'WiFi',
        'Kitchen',
        'City Views',
        'Air Conditioning',
        'Workspace'
      ],
      bedrooms: 0,
      bathrooms: 1,
      guests: 2,
      propertyType: 'Studio',
      latitude: 34.0522,
      longitude: -118.2437,
    ),
  ];

  static List<Property> getFeaturedProperties() {
    return properties.take(3).toList();
  }

  static List<Property> getPropertiesByType(String type) {
    return properties
        .where((property) =>
            property.propertyType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  static List<Property> getSavedProperties() {
    return properties.where((property) => property.isFavorite).toList();
  }
}
