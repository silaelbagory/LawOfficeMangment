import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthCubit(this._authRepository, this._userRepository) : super(AuthInitial());

  void _init() {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserData();
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      
      if (_authRepository.isSignedIn) {
        await _loadUserData();
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication status: $e'));
    }
  }

  // Load user data
  Future<void> _loadUserData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to load user data: $e'));
    }
  }

  // Sign in with email and password
// Sign in with email and password
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    emit(AuthLoading());

    final user = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (user != null) {
      // ✅ جِيب بيانات المستخدم من الـ repository
      final userData = await _userRepository.getUser(user.id);

      if (userData == null) {
        emit(AuthError('User data not found.'));
        return;
      }

      // ✅ تحقق إذا كان محامي وغير active
      if (userData.role == UserRole.lawyer && userData.isActive == false) {
        emit(AuthError(
          'You are not active. Please ask your manager  to activate your account.',
        ));
        await _authRepository.signOut();
        return;
      }

      // ✅ لو كل شيء تمام
      emit(AuthAuthenticated(userData));
    } else {
      emit(AuthError('Sign in failed. Please check your credentials.'));
    }
  } catch (e) {
    emit(AuthError('Sign in failed: $e'));
  }
}


  // Create user account (for signup)
  Future<void> createUserAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userId = await _userRepository.createUser(
        name: name,
        email: email,
        password: password,
        role: UserRole.manager,
        permissions: UserPermissions.manager(),
        status: UserStatus.pending,
      );
      final user = await _userRepository.getUser(userId);
      if (user != null) {
        emit(AuthAccountCreated(user));
        await FirebaseAuth.instance.signOut();
 
      } else {
        emit(AuthError('Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('Registration failed: $e'));
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      
      final user = await _authRepository.signInWithGoogle();
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Google sign in failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('Google sign in failed: $e'));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed: $e'));
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      emit(AuthError('Password reset failed: $e'));
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
  }) async {
    try {
      emit(AuthLoading());
      await _authRepository.updateUserProfile(name: name);
      await _loadUserData(); // Reload user data
    } catch (e) {
      emit(AuthError('Profile update failed: $e'));
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      emit(AuthLoading());
      await _authRepository.updatePassword(newPassword);
    } catch (e) {
      emit(AuthError('Password update failed: $e'));
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      emit(AuthLoading());
      await _authRepository.deleteUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Account deletion failed: $e'));
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      emit(AuthError('Email verification failed: $e'));
    }
  }

  // Get current user
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    return state is AuthAuthenticated;
  }

  // Check if user is loading
  bool get isLoading {
    return state is AuthLoading;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is AuthError) {
      return currentState.message;
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }

  // Check if user has specific role
  Future<bool> hasRole(UserRole role) async {
    return await _authRepository.hasRole(role);
  }

  // Check if user is manager
  Future<bool> isManager() async {
    return await _authRepository.isManager();
  }

  // Check if user is lawyer
  Future<bool> isLawyer() async {
    return await _authRepository.isLawyer();
  }

  // Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    return await _authRepository.hasPermission(permission);
  }

  // Check if user can perform action
  Future<bool> canPerformAction(String permission) async {
    return await _authRepository.canPerformAction(permission);
  }
}