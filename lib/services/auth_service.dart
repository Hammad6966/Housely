import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

        // Save to Firestore
        await _firestore.collection('users').doc(uid).set(_currentUser!.toJson());

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
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      _currentUser = User.fromJson(doc.data()!);
    } else {
      // Handle case where auth exists but firestore doc is missing
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
