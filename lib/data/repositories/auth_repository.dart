import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/firebase_auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository(this._authService, this._firestoreService);

  // Get current user
  User? get currentUser => _authService.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Get user data from Firestore
        final userData = await _firestoreService.getDocument(
          collection: 'users',
          documentId: user.uid,
        );
        
        if (userData != null) {
          final userModel = UserModel.fromMap(userData);
          
          // Check if user is approved and active
          if (userModel.status == UserStatus.approved || userModel.status == UserStatus.active) {
            return userModel;
          } else if (userModel.status == UserStatus.pending) {
            throw Exception('Your account is pending approval. Please contact your administrator.');
          } else if (userModel.status == UserStatus.rejected) {
            throw Exception('Your account has been rejected. Please contact your administrator.');
          } else {
            throw Exception('Your account is inactive. Please contact your administrator.');
          }
        } else {
          // User doesn't exist in Firestore - this shouldn't happen in RBAC system
          throw Exception('User not found in system. Please contact administrator.');
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Create user account (for signup)
  Future<UserModel?> createUserAccount({
    required String name,
    required String email,
    required String password,
    
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Update user profile with display name
        await _authService.updateUserProfile(displayName: name);
        
        // Create user document in Firestore with pending status
        final newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          role: UserRole.lawyer, // Default to lawyer, can be changed by manager
          permissions: const UserPermissions(), // No permissions by default
          status: UserStatus.pending, // Pending approval
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        await _firestoreService.createDocument(
          collection: 'users',
          documentId: user.uid,
          data: newUser.toMap(),
        );
        
        // Sign out the user since they need approval
        await _authService.signOut();
        
        return newUser;
      }
      
      return null;
    } catch (e) {
      throw Exception('Account creation failed: $e');
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Get user data from Firestore
        final userData = await _firestoreService.getDocument(
          collection: 'users',
          documentId: user.uid,
        );
        
        if (userData != null) {
          return UserModel.fromMap(userData);
        } else {
          // User doesn't exist in Firestore - this shouldn't happen in RBAC system
          throw Exception('User not found in system. Please contact administrator.');
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final userData = await _firestoreService.getDocument(
        collection: 'users',
        documentId: user.uid,
      );
      
      if (userData != null) {
        return UserModel.fromMap(userData);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile
      await _authService.updateUserProfile(displayName: name);

      // Update Firestore document
      final userData = await _firestoreService.getDocument(
        collection: 'users',
        documentId: user.uid,
      );
      
      if (userData != null) {
        final currentUser = UserModel.fromMap(userData);
        final updatedUser = currentUser.copyWith(
          name: name,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateDocument(
          collection: 'users',
          documentId: user.uid,
          data: updatedUser.toMap(),
        );
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user document from Firestore
      await _firestoreService.deleteDocument(
        collection: 'users',
        documentId: user.uid,
      );

      // Delete user from Firebase Auth
      await _authService.deleteUser();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  // Get user ID
  String? get userId => _authService.userId;

  // Get user email
  String? get userEmail => _authService.userEmail;

  // Get user display name
  String? get userDisplayName => _authService.userDisplayName;

  // Get user photo URL
  String? get userPhotoURL => _authService.userPhotoURL;

  // Check if user is signed in
  bool get isSignedIn => _authService.isSignedIn;

  // Check if user has specific role
  Future<bool> hasRole(UserRole role) async {
    try {
      final user = await getCurrentUser();
      return user?.role == role;
    } catch (e) {
      return false;
    }
  }

  // Check if user is manager
  Future<bool> isManager() async {
    return await hasRole(UserRole.manager);
  }

  // Check if user is lawyer
  Future<bool> isLawyer() async {
    return await hasRole(UserRole.lawyer);
  }

  // Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        return user.hasPermission(permission);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can perform action
  Future<bool> canPerformAction(String permission) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Managers can do everything
      if (user.isManager) {
        return true;
      }

      // Check specific permission for lawyers
      return user.hasPermission(permission);
    } catch (e) {
      return false;
    }
  }

  // Get current user with permissions
  Future<UserModel?> getCurrentUserWithPermissions() async {
    return await getCurrentUser();
  }
}