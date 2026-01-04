import 'dart:developer';

import 'package:happy_pet_dashboard/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/enums/app_enums.dart';
import '../../domain/models/user_model.dart';
import 'base_repository.dart';

/// Repository for authentication operations
class AuthRepository extends BaseRepository {
  GoTrueClient get auth => client.auth;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    log('signInWithEmail: $email');
    log('signInWithEmail: $password');
    try {
      final response = await auth.signInWithPassword(email: email, password: password.trim());
      return response;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current user session
  Session? get currentSession => auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await auth.resetPasswordForEmail(email);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await auth.updateUser(UserAttributes(password: newPassword));
      return response;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get current user profile from users table
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await from('users').select().eq('id', currentUser!.id).maybeSingle();
      if (response != null) {
        final user = UserModel.fromJson(response);
        log(user.toString());
        return user;
      }
      return null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create user profile after signup
  Future<UserModel> createUserProfile({
    required String userId,
    required String fullName,
    required UserRole role,
    String? email,
    String? phone,
    String? hotelId,
  }) async {
    try {
      final userProfile = {
        'id': userId,
        'full_name': fullName,
        'email': email,
        'role': role.name,
        'phone': phone,
        'hotel_id': hotelId,
        'is_active': true,
      };

      final response = await from('users').upsert(userProfile).select().single();
      return UserModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Signup a new user (Auth + Profile) without disrupting current session.
  /// Note: This uses a secondary client to avoid session conflicts.
  Future<UserModel> signupNewUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? hotelId,
  }) async {
    try {
      // Create a temporary client to perform signup
      // We use the same URL and Anon Key from the global instance
      final tempClient = SupabaseClient(
        SupabaseService.supabaseUrl!,
        SupabaseService.supabaseAnonKey!,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      );

      final authResponse = await tempClient.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName},
      );

      if (authResponse.user == null) {
        throw RepositoryException('Failed to create auth user');
      }

      // Create the profile using the MAIN client (authenticated as admin)
      return await createUserProfile(
        userId: authResponse.user!.id,
        fullName: fullName,
        email: email,
        role: role,
        hotelId: hotelId,
      );
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await from('users').update(user.toJson()).eq('id', user.id).select().single();
      return UserModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await auth.refreshSession();
      return response;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Check if there are any admin users in the database
  Future<bool> hasAnyAdmin() async {
    try {
      final response = await from('users').select('id').eq('role', UserRole.admin.name).limit(1).maybeSingle();
      return response != null;
    } on Exception {
      return false;
    }
  }
}
