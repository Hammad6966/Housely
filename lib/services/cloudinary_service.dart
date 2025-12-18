import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// A reusable service for uploading images to Cloudinary.
/// Uses unsigned upload preset - safe for client-side uploads.
/// Does NOT store anything in Firebase - only handles Cloudinary uploads.
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // ============================================================
  // SAFE TO EXPOSE - These are public values for unsigned uploads
  // NEVER add API_SECRET or API_KEY here!
  // ============================================================
  static const String _cloudName = 'dyuh0ezn2';
  static const String _uploadPreset = 'housely_unsigned';
  
  static String get _uploadUrl => 
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload an image file to Cloudinary
  /// 
  /// [imageFile] - The image file to upload
  /// [folder] - Optional subfolder (e.g., 'profiles', 'properties')
  /// [publicId] - Optional custom public ID for the image
  /// 
  /// Returns the secure_url as String on success
  /// Throws [CloudinaryException] on failure
  Future<String> uploadImage({
    required File imageFile,
    String? folder,
    String? publicId,
  }) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw CloudinaryException('File does not exist');
      }

      // Build the multipart request
      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add required upload preset (unsigned)
      request.fields['upload_preset'] = _uploadPreset;
      
      // Add optional folder path
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = 'housely/$folder';
      }
      
      // Add optional custom public ID
      if (publicId != null && publicId.isNotEmpty) {
        request.fields['public_id'] = publicId;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response
      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final secureUrl = body['secure_url'] as String?;
        if (secureUrl == null || secureUrl.isEmpty) {
          throw CloudinaryException('No secure_url in response');
        }
        return secureUrl;
      } else {
        // Extract error message from Cloudinary response
        final error = body['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Unknown error';
        throw CloudinaryException(message);
      }
    } on CloudinaryException {
      rethrow;
    } on SocketException {
      throw CloudinaryException('No internet connection');
    } on FormatException {
      throw CloudinaryException('Invalid response from server');
    } catch (e) {
      throw CloudinaryException('Upload failed: $e');
    }
  }

  /// Convenience method: Upload profile image
  /// Returns secure_url as String
  Future<String> uploadProfileImage(File imageFile, String userId) {
    return uploadImage(
      imageFile: imageFile,
      folder: 'profiles',
      publicId: 'user_$userId',
    );
  }

  /// Convenience method: Upload property image
  /// Returns secure_url as String
  Future<String> uploadPropertyImage(File imageFile, String propertyId, int index) {
    return uploadImage(
      imageFile: imageFile,
      folder: 'properties',
      publicId: 'property_${propertyId}_$index',
    );
  }
}

/// Custom exception for Cloudinary upload errors
class CloudinaryException implements Exception {
  final String message;
  
  CloudinaryException(this.message);
  
  @override
  String toString() => 'CloudinaryException: $message';
}
