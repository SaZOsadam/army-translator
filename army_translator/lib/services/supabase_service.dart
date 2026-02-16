import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // ============ AUTHENTICATION ============

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      await _createUserProfile(response.user!);
    }
    
    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  static Future<bool> signInWithGoogle() async {
    final response = await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: SupabaseConfig.redirectUrl,
    );
    return response;
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Create user profile in database
  static Future<void> _createUserProfile(User user) async {
    await client.from(SupabaseConfig.usersTable).upsert({
      'id': user.id,
      'email': user.email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ============ USER PROFILE ============

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    final response = await client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return response;
  }

  // ============ TRANSLATION SESSIONS ============

  /// Save translation session
  static Future<Map<String, dynamic>> saveSession({
    required String title,
    required int duration,
    required int lineCount,
  }) async {
    final response = await client
        .from(SupabaseConfig.sessionsTable)
        .insert({
          'user_id': currentUser!.id,
          'title': title,
          'duration': duration,
          'line_count': lineCount,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    
    return response;
  }

  /// Get user's sessions
  static Future<List<Map<String, dynamic>>> getUserSessions() async {
    if (currentUser == null) return [];
    
    final response = await client
        .from(SupabaseConfig.sessionsTable)
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get session with subtitles
  static Future<Map<String, dynamic>?> getSessionWithSubtitles(String sessionId) async {
    final sessionResponse = await client
        .from(SupabaseConfig.sessionsTable)
        .select()
        .eq('id', sessionId)
        .single();
    
    final subtitlesResponse = await client
        .from(SupabaseConfig.subtitlesTable)
        .select()
        .eq('session_id', sessionId)
        .order('timestamp', ascending: true);
    
    return {
      'session': sessionResponse,
      'subtitles': subtitlesResponse,
    };
  }

  /// Delete session
  static Future<void> deleteSession(String sessionId) async {
    await client
        .from(SupabaseConfig.sessionsTable)
        .delete()
        .eq('id', sessionId);
  }

  // ============ SUBTITLES ============

  /// Save subtitles for a session
  static Future<void> saveSubtitles(String sessionId, List<Map<String, dynamic>> subtitles) async {
    final data = subtitles.map((s) => {
      ...s,
      'session_id': sessionId,
    }).toList();
    
    await client.from(SupabaseConfig.subtitlesTable).insert(data);
  }

  // ============ USER STATS ============

  /// Get user stats
  static Future<Map<String, dynamic>?> getUserStats() async {
    if (currentUser == null) return null;
    
    final response = await client
        .from(SupabaseConfig.userStatsTable)
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();
    
    return response;
  }

  /// Update user stats
  static Future<void> updateStats({
    int sessionsCount = 0,
    int totalMinutes = 0,
    int totalLines = 0,
  }) async {
    if (currentUser == null) return;
    
    await client.rpc('update_user_stats', params: {
      'p_user_id': currentUser!.id,
      'p_sessions': sessionsCount,
      'p_minutes': totalMinutes,
      'p_lines': totalLines,
    });
  }
}
