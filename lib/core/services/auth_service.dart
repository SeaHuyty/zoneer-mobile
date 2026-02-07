// Core Services - Authentication Service
// This file contains the authentication service for managing user sessions
// Handles login, logout, token management, and authentication state
// Provides authentication status across the entire app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  bool get isAuthenticated => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullname,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  Future<void> signout() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});
