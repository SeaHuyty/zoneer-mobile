// Core Services - Authentication Service
// This file contains the authentication service for managing user sessions
// Handles login, logout, token management, and authentication state
// Provides authentication status across the entire app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  bool get isAuthenticated => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChange => _client.auth.onAuthStateChange;



Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000',
      );
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '102797929514-9hc3rsmdvrr7akt18qudem29l7uegjpl.apps.googleusercontent.com.apps.googleusercontent.com', 
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get idToken');
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
    }
  }
  
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
