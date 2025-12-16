import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _currentUser;

  // Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const AuthResult(
          success: false,
          message: 'Please fill in all fields',
        );
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        return AuthResult(
          success: true,
          message: 'Login successful',
          user: _currentUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Login failed',
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: e.message ?? 'An error occurred during login',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // Signup with user details
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        return const AuthResult(
          success: false,
          message: 'Please fill in all required fields',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;
        
        // Create user model
        _currentUser = User(
          id: uid,
          email: email.trim(),
          fullName: fullName,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          isVerified: false,
        );

        // Save to Realtime Database
        await _database.child('users').child(uid).set(_currentUser!.toJson());

        return AuthResult(
          success: true,
          message: 'Account created successfully',
          user: _currentUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Signup failed',
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: e.message ?? 'An error occurred during signup',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // Upload profile image
  Future<AuthResult> uploadProfileImage(File imageFile) async {
    try {
      if (_currentUser == null) {
        return const AuthResult(
          success: false,
          message: 'You must be logged in to upload a profile image',
        );
      }

      final userId = _currentUser!.id;
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      // Update user in Realtime Database
      await _database.child('users').child(userId).update({
        'profileImage': downloadUrl,
      });
      
      // Update local user object
      _currentUser = _currentUser!.copyWith(profileImage: downloadUrl);
      
      return AuthResult(
        success: true,
        message: 'Profile image updated successfully',
        user: _currentUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to upload profile image: $e',
      );
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // Check if user is already logged in (for app startup)
  Future<bool> checkAuthStatus() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _loadUserData(firebaseUser.uid);
        return true;
      } catch (e) {
        // If we can't load user data, sign out
        await logout();
        return false;
      }
    }
    return false;
  }

  Future<void> _loadUserData(String uid) async {
    final snapshot = await _database.child('users').child(uid).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _currentUser = User.fromJson(data);
    } else {
      // Handle case where auth exists but database doc is missing
      // For now, create a basic user object from auth data
      _currentUser = User(
        id: uid,
        email: _auth.currentUser?.email ?? '',
        fullName: _auth.currentUser?.displayName ?? 'User',
        createdAt: DateTime.now(),
        isVerified: _auth.currentUser?.emailVerified ?? false,
      );
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
