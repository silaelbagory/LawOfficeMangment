import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/user_management_service.dart';
import '../../data/models/user_model.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserManagementService _userManagementService;

  UserCubit(this._userManagementService) : super(UserInitial());

  // Get current user
  Future<void> getCurrentUser() async {
    try {
      emit(UserLoading());
      
      final user = await _userManagementService.getCurrentUserWithPermissions();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError('Failed to get current user: $e'));
    }
  }

  // Add a new lawyer
  Future<void> addLawyer({
    required String name,
    required String email,
    required String password,
    required UserPermissions permissions,
  }) async {
    try {
      emit(UserLoading());
      
      final lawyerId = await _userManagementService.addLawyer(
        name: name,
        email: email,
        password: password,
        permissions: permissions,
      );
      
      emit(UserCreated(lawyerId));
      
      // Reload lawyers list
      await getMyLawyers();
    } catch (e) {
      emit(UserError('Failed to add lawyer: $e'));
    }
  }

  // Get all lawyers
  Future<void> getMyLawyers() async {
    try {
      emit(UserLoading());
      
      final lawyers = await _userManagementService.getMyLawyers();
      emit(UsersLoaded(lawyers));
    } catch (e) {
      emit(UserError('Failed to get lawyers: $e'));
    }
  }

  // Update lawyer permissions
  Future<void> updateLawyerPermissions({
    required String lawyerId,
    required UserPermissions permissions,
  }) async {
    try {
      emit(UserLoading());
      
      await _userManagementService.updateLawyerPermissions(
        lawyerId: lawyerId,
        permissions: permissions,
      );
      
      emit(UserPermissionsUpdated(
        UserModel(
          id: lawyerId,
          name: '',
          email: '',
          role: UserRole.lawyer,
          permissions: permissions,
          createdAt: DateTime.now(), status: UserStatus.approved        ),
      ));
      
      // Reload lawyers list
      await getMyLawyers();
    } catch (e) {
      emit(UserError('Failed to update lawyer permissions: $e'));
    }
  }

  // Deactivate lawyer
  Future<void> deactivateLawyer(String lawyerId) async {
    try {
      emit(UserLoading());
      
      await _userManagementService.deactivateLawyer(lawyerId);
      emit(UserDeactivated(lawyerId));
      
      // Reload lawyers list
      await getMyLawyers();
    } catch (e) {
      emit(UserError('Failed to deactivate lawyer: $e'));
    }
  }

  // Activate lawyer
  Future<void> activateLawyer(String lawyerId) async {
    try {
      emit(UserLoading());
      
      await _userManagementService.activateLawyer(lawyerId);
      emit(UserActivated(lawyerId));
      
      // Reload lawyers list
      await getMyLawyers();
    } catch (e) {
      emit(UserError('Failed to activate lawyer: $e'));
    }
  }

  // Check if current user can perform action
  Future<void> checkPermission(String permission) async {
    try {
      final canPerform = await _userManagementService.canPerformAction(permission);
      emit(UserPermissionChecked(canPerform));
    } catch (e) {
      emit(UserError('Failed to check permission: $e'));
    }
  }

  // Update current user profile
  Future<void> updateCurrentUserProfile({
    required String name,
  }) async {
    try {
      emit(UserLoading());
      
      await _userManagementService.updateCurrentUserProfile(name: name);
      
      // Reload current user
      await getCurrentUser();
    } catch (e) {
      emit(UserError('Failed to update profile: $e'));
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      emit(UserLoading());
      
      await _userManagementService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      // Reload current user
      await getCurrentUser();
    } catch (e) {
      emit(UserError('Failed to change password: $e'));
    }
  }

  // Get current user from state
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is UserLoaded) {
      return currentState.user;
    }
    return null;
  }

  // Get all lawyers from state
  List<UserModel> get currentLawyers {
    final currentState = state;
    if (currentState is UsersLoaded) {
      return currentState.users;
    }
    return [];
  }

  // Check if loading
  bool get isLoading {
    return state is UserLoading;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is UserError) {
      return currentState.message;
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is UserError) {
      emit(UserInitial());
    }
  }

  // Load pending users
  Future<void> loadPendingUsers() async {
    try {
      emit(UserLoading());
      
      final pendingUsers = await _userManagementService.getPendingUsers();
      emit(UsersLoaded(pendingUsers));
    } catch (e) {
      emit(UserError('Failed to load pending users: $e'));
    }
  }

  // Approve user
 // Future<void> approveUser(String userId, UserRole role, UserPermissions permissions) async {
 //   try {
 ////     emit(UserLoading());
      
 //////     await _userManagementService.approveUser(userId, role, permissions);
//emit(UserUpdated());
      
      // Reload pending users
///await loadPendingUsers();
  //  } catch (e) {
  //    emit(UserError('Failed to approve user: $e'));
    //}
  //}

  // Reject user
 // Future<void> rejectUser(String userId) async {
  //  try {
    //  emit(UserLoading());
      
      //await _userManagementService.rejectUser(userId);
      //emit(UserUpdated());
      
      // Reload pending users
      //await loadPendingUsers();
   // } catch (e) {
     // emit(UserError('Failed to reject user: $e'));
    //}
  }

  // Update user status
 // Future<void> updateUserStatus(String userId, UserStatus status) async {
   // try {
     // emit(UserLoading());
      
     // await _userManagementService.updateUserStatus(userId, status);
     //  emit(UserUpdated());
      
      // Reload users
//      await loadUsers();
  //  } catch (e) {
    //  emit(UserError('Failed to update user status: $e'));
   // }
 // }
//}
