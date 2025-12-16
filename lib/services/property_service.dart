import 'package:firebase_database/firebase_database.dart';
import '../models/property.dart';
import 'auth_service.dart';

class PropertyService {
  static final PropertyService _instance = PropertyService._internal();
  factory PropertyService() => _instance;
  PropertyService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AuthService _authService = AuthService();

  // Add a new property
  Future<PropertyResult> addProperty(Property property) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return const PropertyResult(
          success: false,
          message: 'You must be logged in to add a property',
        );
      }

      final newPropertyRef = _database.child('properties').push();
      final propertyWithId = property.copyWith(
        id: newPropertyRef.key!,
        ownerId: user.id,
        hostName: user.fullName,
        hostAvatar: user.profileImage ?? '',
        createdAt: DateTime.now(),
      );

      await newPropertyRef.set(propertyWithId.toJson());

      return PropertyResult(
        success: true,
        message: 'Property added successfully',
        property: propertyWithId,
      );
    } catch (e) {
      return PropertyResult(
        success: false,
        message: 'Failed to add property: $e',
      );
    }
  }

  // Get all properties
  Future<List<Property>> getAllProperties() async {
    try {
      final snapshot = await _database
          .child('properties')
          .orderByChild('createdAt')
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final properties = data.entries.map((entry) {
        final propertyData = Map<String, dynamic>.from(entry.value as Map);
        return Property.fromJson(propertyData);
      }).toList();

      // Sort by createdAt descending (newest first)
      properties.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      return properties;
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  // Get properties stream for real-time updates
  Stream<List<Property>> getPropertiesStream() {
    return _database
        .child('properties')
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <Property>[];
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final properties = data.entries.map((entry) {
        final propertyData = Map<String, dynamic>.from(entry.value as Map);
        return Property.fromJson(propertyData);
      }).toList();

      // Sort by createdAt descending (newest first)
      properties.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      return properties;
    });
  }

  // Get properties by user
  Future<List<Property>> getUserProperties(String userId) async {
    try {
      final snapshot = await _database
          .child('properties')
          .orderByChild('ownerId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final properties = data.entries.map((entry) {
        final propertyData = Map<String, dynamic>.from(entry.value as Map);
        return Property.fromJson(propertyData);
      }).toList();

      // Sort by createdAt descending (newest first)
      properties.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      return properties;
    } catch (e) {
      print('Error fetching user properties: $e');
      return [];
    }
  }

  // Update property
  Future<PropertyResult> updateProperty(Property property) async {
    try {
      await _database
          .child('properties')
          .child(property.id)
          .update(property.toJson());

      return PropertyResult(
        success: true,
        message: 'Property updated successfully',
        property: property,
      );
    } catch (e) {
      return PropertyResult(
        success: false,
        message: 'Failed to update property: $e',
      );
    }
  }

  // Delete property
  Future<PropertyResult> deleteProperty(String propertyId) async {
    try {
      await _database.child('properties').child(propertyId).remove();

      return const PropertyResult(
        success: true,
        message: 'Property deleted successfully',
      );
    } catch (e) {
      return PropertyResult(
        success: false,
        message: 'Failed to delete property: $e',
      );
    }
  }
}

class PropertyResult {
  final bool success;
  final String message;
  final Property? property;

  const PropertyResult({
    required this.success,
    required this.message,
    this.property,
  });
}
