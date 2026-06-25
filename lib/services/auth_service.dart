import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> initialize() async {
    // clientId (iOS) is read from GIDClientID in Info.plist.
    // serverClientId causes the ID token's aud to be the web client ID,
    // which is what Supabase validates against.
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      debugPrint('[Auth] Google authenticate() succeeded. idToken null: ${idToken == null}');
      if (idToken == null) throw Exception('Google sign-in failed: no ID token received');

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      debugPrint('[Auth] Supabase signInWithIdToken succeeded');
    } on GoogleSignInException catch (e) {
      debugPrint('[Auth] GoogleSignInException: code=${e.code} description=${e.description} details=${e.details}');
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    } on AuthApiException catch (e, st) {
      debugPrint('[Auth] AuthApiException: statusCode=${e.statusCode} message=${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[Auth] sign-in error: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _client.rpc('delete_user');
    await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }
}
