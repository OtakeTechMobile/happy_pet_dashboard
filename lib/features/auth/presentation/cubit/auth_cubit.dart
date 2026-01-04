import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/enums/app_enums.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription _authStateSubscription;

  AuthCubit(this._authRepository) : super(const AuthState.unknown()) {
    _init();
  }

  void _init() {
    // Check initial session
    final session = _authRepository.currentSession;
    if (session != null) {
      _loadUserProfile();
    } else {
      emit(const AuthState.unauthenticated());
    }

    // Listen to auth changes
    _authStateSubscription = _authRepository.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> _loadUserProfile() async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        var profile = await _authRepository.getCurrentUserProfile();

        // [Rescue Mechanism] If no profile exists and no admins are in the system,
        // we bootstrap the current user as an admin.
        if (profile == null) {
          try {
            final hasAdmin = await _authRepository.hasAnyAdmin();
            if (!hasAdmin) {
              log('No admins found in database. Bootstrapping current user as Admin.');
              profile = await _authRepository.createUserProfile(
                userId: user.id,
                fullName: user.userMetadata?['full_name'] ?? 'Super Admin',
                role: UserRole.admin,
                email: user.email,
              );
            }
          } catch (e) {
            log('Error bootstrapping admin (likely RLS): $e');
            // If bootstrap fails, we still continue so the user can see the app,
            // even if they don't have an admin profile yet.
          }
        }

        emit(AuthState.authenticated(user, profile));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      log(user.user.toString());
      // State update handled by listener, but we can double check or wait
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final res = await _authRepository.auth.signUp(email: email, password: password);

      if (res.user != null) {
        await _authRepository.createUserProfile(
          userId: res.user!.id,
          fullName: fullName,
          role: role,
          phone: phone,
          hotelId: null, // Initial user has no hotel or creates one later
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
