// Core Services - Authentication Service
// This file contains the authentication service for managing user sessions
// Handles login, logout, token management, and authentication state
// Provides authentication status across the entire app

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  bool get isAuthenticated => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChange => _client.auth.onAuthStateChange;

  String _getWebGoogleRedirectTo() {
    const configuredRedirect = String.fromEnvironment(
      'WEB_GOOGLE_REDIRECT_TO',
      defaultValue: '',
    );
    const debugRedirect = String.fromEnvironment(
      'WEB_GOOGLE_REDIRECT_TO_DEBUG',
      defaultValue: '',
    );
    const releaseRedirect = String.fromEnvironment(
      'WEB_GOOGLE_REDIRECT_TO_RELEASE',
      defaultValue: '',
    );

    if (kDebugMode && debugRedirect.isNotEmpty) return debugRedirect;
    if (!kDebugMode && releaseRedirect.isNotEmpty) return releaseRedirect;
    if (configuredRedirect.isNotEmpty) return configuredRedirect;

    // Default to the active web origin so OAuth callbacks work outside localhost.
    return Uri.base.origin;
  }
Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getWebGoogleRedirectTo(),
      );
    } else {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
      const scopes = ['email', 'profile'];

      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
        clientId: iosClientId.isNotEmpty ? iosClientId : null,
      );

      // Tries silent sign-in first; falls back to null (no UI shown)
      final googleUser =
          await GoogleSignIn.instance.attemptLightweightAuthentication() ??
          await GoogleSignIn.instance.authenticate();

      // Fetch access token with the required scopes
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw AuthException('No ID Token found.');

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
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
