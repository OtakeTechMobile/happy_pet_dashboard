import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../domain/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final UserModel? userProfile;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.userProfile,
    this.errorMessage,
    this.isLoading = false,
  });

  const AuthState.unknown() : this();

  const AuthState.authenticated(User user, UserModel? profile)
    : this(status: AuthStatus.authenticated, user: user, userProfile: profile);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user, userProfile, errorMessage, isLoading];

  AuthState copyWith({AuthStatus? status, User? user, UserModel? userProfile, String? errorMessage, bool? isLoading}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
