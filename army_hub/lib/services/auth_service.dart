import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.armyapps.armyhub://login-callback',
      );

      if (!response) return null;

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 1));

      final user = currentUser;
      if (user != null) {
        return await _getOrCreateUser(user);
      }

      return null;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        return await getUserData(user.id);
      }

      return null;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String bias,
    required String language,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': displayName},
      );

      final user = response.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.id,
          email: email,
          displayName: displayName,
          bias: bias,
          language: language,
          createdAt: DateTime.now(),
        );

        await _client.from('users').upsert(userModel.toJson());

        return userModel;
      }

      return null;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final data =
          await _client.from('users').select().eq('id', uid).maybeSingle();

      if (data != null) {
        return UserModel.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<UserModel?> _getOrCreateUser(User user) async {
    final data =
        await _client.from('users').select().eq('id', user.id).maybeSingle();

    if (data != null) {
      return UserModel.fromJson(data);
    }

    final newUser = UserModel(
      uid: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['username'] ?? 'ARMY',
      photoUrl: user.userMetadata?['avatar_url'],
      bias: 'OT7',
      language: 'en',
      createdAt: DateTime.now(),
    );

    await _client.from('users').upsert(newUser.toJson()..['id'] = user.id);

    return newUser;
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? bias,
    String? language,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};

    if (displayName != null) updates['username'] = displayName;
    if (bias != null) updates['bias'] = bias;
    if (language != null) updates['language'] = language;
    if (photoUrl != null) updates['avatar_url'] = photoUrl;

    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', uid);
    }
  }

  Future<void> incrementTheoriesGenerated(String uid) async {
    await _client.rpc('increment_theories', params: {'user_id': uid});
  }

  Exception _handleAuthError(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('user not found')) {
      return Exception('No account found with this email.');
    } else if (message.contains('invalid password') ||
        message.contains('wrong password')) {
      return Exception('Incorrect password.');
    } else if (message.contains('already registered') ||
        message.contains('already in use')) {
      return Exception('An account already exists with this email.');
    } else if (message.contains('weak password')) {
      return Exception('Password is too weak. Use at least 6 characters.');
    } else if (message.contains('invalid email')) {
      return Exception('Invalid email address.');
    } else if (message.contains('too many')) {
      return Exception('Too many attempts. Please try again later.');
    }
    return Exception(e.message);
  }
}
