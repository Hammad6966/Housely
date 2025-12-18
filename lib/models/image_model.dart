class ImageModel {
  final String id;
  final String imageUrl;
  final String userId;
  final String? referenceId;    // e.g., propertyId
  final String? referenceType;  // e.g., 'property', 'profile'
  final String? publicId;       // Cloudinary public_id for deletion
  final DateTime createdAt;

  ImageModel({
    required this.id,
    required this.imageUrl,
    required this.userId,
    this.referenceId,
    this.referenceType,
    this.publicId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'userId': userId,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'publicId': publicId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      publicId: json['publicId'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  ImageModel copyWith({
    String? id,
    String? imageUrl,
    String? userId,
    String? referenceId,
    String? referenceType,
    String? publicId,
    DateTime? createdAt,
  }) {
    return ImageModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      publicId: publicId ?? this.publicId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
