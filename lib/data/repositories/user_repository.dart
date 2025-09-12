import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/firestore_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserRepository(this._firestoreService);

  // Create a new user (for managers adding lawyers)
  Future<String> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required UserPermissions permissions,
    required UserStatus status,
    String? createdBy, // ID of the manager creating this user
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        role: role,
        permissions: permissions,
        status: status,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestoreService.createDocument(
        collection: 'users',
        documentId: user.uid,
        data: userModel.toMap(),
      );

      return user.uid;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final userData = await _firestoreService.getDocument(
        collection: 'users',
        documentId: userId,
      );
      
      if (userData != null) {
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return await getUser(currentUser.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, UserModel userModel) async {
    try {
      final updatedUser = userModel.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateDocument(
        collection: 'users',
        documentId: userId,
        data: updatedUser.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update user permissions
  Future<void> updateUserPermissions(String userId, UserPermissions permissions) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          permissions: permissions,
          updatedAt: DateTime.now(),
        );
        await updateUser(userId, updatedUser);
      }
    } catch (e) {
      throw Exception('Failed to update user permissions: $e');
    }
  }

  // Get all users (for managers)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final usersData = await _firestoreService.getCollection(
        collection: 'users',
        orderBy: 'createdAt',
        descending: true,
      );

      return usersData.map((data) => UserModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Get all lawyers (for managers)
  Future<List<UserModel>> getLawyers() async {
    try {
      final usersData = await _firestoreService.getCollection(
        collection: 'users',
        whereConditions: {'role': UserRole.lawyer.value},
        orderBy: 'createdAt',
        descending: true,
      );

      return usersData.map((data) => UserModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get lawyers: $e');
    }
  }

  // Get lawyers created by a specific manager
  Future<List<UserModel>> getLawyersByManager(String managerId) async {
    try {
      final usersData = await _firestoreService.getCollection(
        collection: 'users',
        whereConditions: {
          'role': UserRole.lawyer.value,
          'createdBy': managerId,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return usersData.map((data) => UserModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get lawyers by manager: $e');
    }
  }

  // Deactivate user
  Future<void> deactivateUser(String userId) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await updateUser(userId, updatedUser);
      }
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  // Activate user
  Future<void> activateUser(String userId) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        );
        await updateUser(userId, updatedUser);
      }
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  // Delete user (soft delete by deactivating)
  Future<void> deleteUser(String userId) async {
    try {
      await deactivateUser(userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Stream users for real-time updates
  Stream<List<UserModel>> streamUsers() {
    return _firestoreService.streamCollection(collection: 'users').map((usersData) {
      return usersData.map((data) => UserModel.fromMap(data)).toList();
    });
  }

  // Stream lawyers for real-time updates
  Stream<List<UserModel>> streamLawyers() {
    return _firestoreService.streamCollection(
      collection: 'users',
      whereConditions: {'role': UserRole.lawyer.value},
    ).map((usersData) {
      return usersData.map((data) => UserModel.fromMap(data)).toList();
    });
  }

  // Check if user has permission
  Future<bool> hasPermission(String userId, String permission) async {
    try {
      final user = await getUser(userId);
      if (user != null) {
        return user.hasPermission(permission);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check permission: $e');
    }
  }

  // Check if current user has permission
  Future<bool> currentUserHasPermission(String permission) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        return currentUser.hasPermission(permission);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check current user permission: $e');
    }
  }

  // Check if current user is manager
  Future<bool> isCurrentUserManager() async {
    try {
      final currentUser = await getCurrentUser();
      return currentUser?.isManager ?? false;
    } catch (e) {
      throw Exception('Failed to check if current user is manager: $e');
    }
  }

  // Check if current user is lawyer
  Future<bool> isCurrentUserLawyer() async {
    try {
      final currentUser = await getCurrentUser();
      return currentUser?.isLawyer ?? false;
    } catch (e) {
      throw Exception('Failed to check if current user is lawyer: $e');
    }
  }

  // Get pending users
  Future<List<UserModel>> getPendingUsers() async {
    try {
      final users = await _firestoreService.getCollection(
        collection: 'users',
        whereConditions: {'status': 'pending'},
        orderBy: 'createdAt',
        descending: true,
      );

      return users.map((data) => UserModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get pending users: $e');
    }
  }

  // Approve user
  Future<void> approveUser(String userId, UserRole role, UserPermissions permissions) async {
    try {
      final user = await getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = user.copyWith(
        role: role,
        permissions: permissions,
        status: UserStatus.approved,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDocument(
        collection: 'users',
        documentId: userId,
        data: updatedUser.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  // Reject user
  Future<void> rejectUser(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = user.copyWith(
        status: UserStatus.rejected,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDocument(
        collection: 'users',
        documentId: userId,
        data: updatedUser.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      final user = await getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = user.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDocument(
        collection: 'users',
        documentId: userId,
        data: updatedUser.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }
}
