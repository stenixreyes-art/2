import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to Authentication State changes in real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user unique ID safely
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign Up with email, password & display name
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create user credential in Firebase Auth service
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // 2. Set displayed profile string
        await user.updateDisplayName(name.trim());

        // 3. Provision primary user metadata document inside secure Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
          'targetCalories': 2000,
          'preferences': {
            'lowCarb': false,
            'lowFat': false,
            'highProtein': false,
          }
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred during user sign-up: $e';
    }
  }

  // Log In with standardized credentials
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Sign in failed. Ensure stable network connection.';
    }
  }

  // Real-time Forgot Password Reset Trigger
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Failed to distribute password reset link.';
    }
  }

  // Secure User Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Gracious extraction of standard user errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password entered is too weak. Must contain at least 6 characters.';
      case 'email-already-in-use':
        return 'An account registers already with this email address.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'user-not-found':
        return 'No user found with these details.';
      case 'wrong-password':
        return 'Incorrect password. Please verify and try again.';
      case 'user-disabled':
        return 'This account is blocked. Contact customer support.';
      case 'invalid-credential':
        return 'Invalid credentials. Enter your registered email address.';
      default:
        return e.message ?? 'Auth transaction failed. Code: ${e.code}';
    }
  }
}