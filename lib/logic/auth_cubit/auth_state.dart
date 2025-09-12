import 'package:equatable/equatable.dart';

import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthEmailSent extends AuthState {
  final String email;

  const AuthEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthProfileUpdated extends AuthState {
  final UserModel user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthPasswordUpdated extends AuthState {}

class AuthAccountDeleted extends AuthState {}

class AuthAccountCreated extends AuthState {
  final UserModel user;

  const AuthAccountCreated(this.user);

  @override
  List<Object?> get props => [user];
}



