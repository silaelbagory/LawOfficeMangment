import '../../data/models/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  UserLoaded(this.user);
}

class UsersLoaded extends UserState {
  final List<UserModel> users;

  UsersLoaded(this.users);
}

class UserCreated extends UserState {
  final String userId;

  UserCreated(this.userId);
}

class UserUpdated extends UserState {
  final UserModel user;

  UserUpdated(this.user);
}

class UserPermissionsUpdated extends UserState {
  final UserModel user;

  UserPermissionsUpdated(this.user);
}

class UserDeactivated extends UserState {
  final String userId;

  UserDeactivated(this.userId);
}

class UserActivated extends UserState {
  final String userId;

  UserActivated(this.userId);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserPermissionChecked extends UserState {
  final bool hasPermission;

  UserPermissionChecked(this.hasPermission);
}
