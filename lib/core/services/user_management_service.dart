import 'package:firebase_auth/firebase_auth.dart';
import 'package:lawofficemanagementsystem/data/models/lawyer_action_model.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/action_repository.dart';
import '../../data/repositories/user_repository.dart';

class UserManagementService {
  final UserRepository _userRepository;
  final ActionRepository _actionRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserManagementService(this._userRepository, this._actionRepository);
  // Add a new lawyer (only managers can do this)
  Future<String> addLawyer({
    required String name,
    required String email,
    required String password,
    required UserPermissions permissions,
  }) async {
    try {
      // Check if current user is manager
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isManager) {
        throw Exception('Only managers can add lawyers');
      }

      // Create the lawyer user
      final lawyerId = await _userRepository.createUser(
        name: name,
        email: email,
        password: password,
        role: UserRole.lawyer,
        permissions: permissions,
        status: UserStatus.approved, // always approved
        createdBy: currentUser.id, // Track which manager created this lawyer
      );

      // Log the action
      await _actionRepository.logAction(
        LawyerActionModel(
          id: '',
          lawyerId: currentUser.id,
          lawyerName: currentUser.name,
          managerId: currentUser.id,
          action: 'Added new lawyer: $name',
          timestamp: DateTime.now(),
          metadata: {
            'actionType': 'add_lawyer',
            'newLawyerId': lawyerId,
            'newLawyerName': name,
            'newLawyerEmail': email,
          },
        ),
      );

      return lawyerId;
    } catch (e) {
      throw Exception('Failed to add lawyer: $e');
    }
  }

  // Update lawyer permissions (only managers can do this)
  Future<void> updateLawyerPermissions({
    required String lawyerId,
    required UserPermissions permissions,
    
  }) async {
    try {
      // Check if current user is manager
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isManager) {
        throw Exception('Only managers can update lawyer permissions');
      }

      // Get the lawyer to update
      final lawyer = await _userRepository.getUser(lawyerId);
      if (lawyer == null) {
        throw Exception('Lawyer not found');
      }

      // Update permissions
      await _userRepository.updateUserPermissions(lawyerId, permissions      );

      // Log the action
      await _actionRepository.logAction(
        LawyerActionModel(
          id: '',
          lawyerId: currentUser.id,
          lawyerName: currentUser.name,
          managerId: currentUser.id,
          action: 'Updated permissions for lawyer: ${lawyer.name}',
          timestamp: DateTime.now(),
          metadata: {
            'actionType': 'update_lawyer_permissions',
            'targetLawyerId': lawyerId,
            'targetLawyerName': lawyer.name,
            'newPermissions': permissions.toMap(),
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to update lawyer permissions: $e');
    }
  }

  // Deactivate lawyer (only managers can do this)
  Future<void> deactivateLawyer(String lawyerId) async {
    try {
      // Check if current user is manager
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isManager) {
        throw Exception('Only managers can deactivate lawyers');
      }

      // Get the lawyer to deactivate
      final lawyer = await _userRepository.getUser(lawyerId);
      if (lawyer == null) {
        throw Exception('Lawyer not found');
      }

      // Deactivate the lawyer
      await _userRepository.deactivateUser(lawyerId      );

      // Log the action
      await _actionRepository.logAction(
        LawyerActionModel(
          id: '',
          lawyerId: currentUser.id,
          lawyerName: currentUser.name,
          managerId: currentUser.id,
          action: 'Deactivated lawyer: ${lawyer.name}',
          timestamp: DateTime.now(),
          metadata: {
            'actionType': 'deactivate_lawyer',
            'targetLawyerId': lawyerId,
            'targetLawyerName': lawyer.name,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to deactivate lawyer: $e');
    }
  }

  // Activate lawyer (only managers can do this)
  Future<void> activateLawyer(String lawyerId) async {
    try {
      // Check if current user is manager
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isManager) {
        throw Exception('Only managers can activate lawyers');
      }

      // Get the lawyer to activate
      final lawyer = await _userRepository.getUser(lawyerId);
      if (lawyer == null) {
        throw Exception('Lawyer not found');
      }

      // Activate the lawyer
      await _userRepository.activateUser(lawyerId      );

      // Log the action
      await _actionRepository.logAction(
        LawyerActionModel(
          id: '',
          lawyerId: currentUser.id,
          lawyerName: currentUser.name,
          managerId: currentUser.id,
          action: 'Activated lawyer: ${lawyer.name}',
          timestamp: DateTime.now(),
          metadata: {
            'actionType': 'activate_lawyer',
            'targetLawyerId': lawyerId,
            'targetLawyerName': lawyer.name,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to activate lawyer: $e');
    }
  }

  // Check if current user can perform action
  Future<bool> canPerformAction(String permission) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Managers can do everything
      if (currentUser.isManager) {
        return true;
      }

      // Check specific permission for lawyers
      return currentUser.hasPermission(permission);
    } catch (e) {
      return false;
    }
  }

  // Get current user with role and permissions
  Future<UserModel?> getCurrentUserWithPermissions() async {
    try {
      return await _userRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  // Get all lawyers (for managers)
  Future<List<UserModel>> getMyLawyrs() async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isManager) {
        throw Exception('Only managers can view all lawyers');
      }

      return await _userRepository.getLawyers();
    } catch (e) {
      throw Exception('Failed to get all lawyers: $e');
    }
  }

  // Get lawyers created by current manager
  Future<List<UserModel>> getMyLawyers() async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (currentUser.isManager) {
        return await _userRepository.getLawyersByManager(currentUser.id);
      } else {
        // If user is a lawyer, return empty list
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get my lawyers: $e');
    }
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile({
    required String name,
  }) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(currentUser.id, updatedUser      );

      // Log the action
      await _actionRepository.logAction(
        LawyerActionModel(
          id: '',
          lawyerId: currentUser.id,
          lawyerName: currentUser.name,
          managerId: currentUser.isManager ? currentUser.id : currentUser.createdBy ?? currentUser.id,
          action: 'Updated profile information',
          timestamp: DateTime.now(),
          metadata: {
            'actionType': 'update_profile',
            'oldName': currentUser.name,
            'newName': name,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newPassword);

      // Log the action
      final userModel = await _userRepository.getCurrentUser();
      if (userModel != null) {
        await _actionRepository.logAction(
          LawyerActionModel(
            id: '',
            lawyerId: userModel.id,
            lawyerName: userModel.name,
            managerId: userModel.isManager ? userModel.id : userModel.createdBy ?? userModel.id,
            action: 'Changed password',
            timestamp: DateTime.now(),
            metadata: {
              'actionType': 'change_password',
            },
          ),
        );
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Get pending users
  Future<List<UserModel>> getPendingUsers() async {
    try {
      return await _userRepository.getPendingUsers();
    } catch (e) {
      throw Exception('Failed to get pending users: $e');
    }
  }

  // Approve user
  Future<void> approveUser(String userId, UserRole role, UserPermissions permissions) async {
    try {
      await _userRepository.approveUser(userId, role, permissions);
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  // Reject user
  Future<void> rejectUser(String userId) async {
    try {
      await _userRepository.rejectUser(userId);
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      await _userRepository.updateUserStatus(userId, status);
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }
}
