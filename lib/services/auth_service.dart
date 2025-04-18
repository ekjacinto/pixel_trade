import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      print('Creating user with email: $email and username: $username');
      
      // Create the user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully with ID: ${userCredential.user?.uid}');

      // Make sure we have a user
      if (userCredential.user == null) {
        throw Exception('Failed to create user - user is null');
      }

      // Update the user's profile with display name
      await userCredential.user!.updateProfile(displayName: username);
      print('Profile updated with display name: $username');

      // Force a reload of the user data
      await userCredential.user!.reload();
      
      // Get the fresh user data
      final updatedUser = _auth.currentUser;
      print('Updated user display name: ${updatedUser?.displayName}');

      // Store additional user data in Firestore
      final userDocRef = _firestore.collection('users').doc(userCredential.user!.uid);
      await userDocRef.set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('User data stored in Firestore');
      
      // Verify the data was stored
      final userDoc = await userDocRef.get();
      print('Verification - Stored user data: ${userDoc.data()}');

      return userCredential;
    } catch (e) {
      print('Error in createUserWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getUserPhotoURL(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['photoURL'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user photo URL: $e');
      return null;
    }
  }

  // Get username by userId
  Future<String?> getUsername(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['username'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }
} 