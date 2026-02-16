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
    String? username,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
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
      'username': user.userMetadata?['username'],
      'bias': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
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

  /// Update user profile
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    await client
        .from(SupabaseConfig.usersTable)
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', currentUser!.id);
  }

  /// Set user's bias
  static Future<void> setBias(String bias) async {
    await updateUserProfile({'bias': bias});
  }

  // ============ THEORIES ============

  /// Get all theories
  static Future<List<Map<String, dynamic>>> getTheories({int limit = 50}) async {
    final response = await client
        .from(SupabaseConfig.theoriesTable)
        .select('*, users(username)')
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get user's theories
  static Future<List<Map<String, dynamic>>> getUserTheories() async {
    if (currentUser == null) return [];
    
    final response = await client
        .from(SupabaseConfig.theoriesTable)
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Create a theory
  static Future<Map<String, dynamic>> createTheory({
    required String title,
    required String content,
    required String prompt,
    List<String>? tags,
  }) async {
    final response = await client
        .from(SupabaseConfig.theoriesTable)
        .insert({
          'user_id': currentUser!.id,
          'title': title,
          'content': content,
          'prompt': prompt,
          'tags': tags ?? [],
          'likes': 0,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    
    return response;
  }

  /// Like a theory
  static Future<void> likeTheory(String theoryId) async {
    await client.rpc('increment_likes', params: {'theory_id': theoryId});
  }

  // ============ POLLS ============

  /// Get active polls
  static Future<List<Map<String, dynamic>>> getActivePolls() async {
    final response = await client
        .from(SupabaseConfig.pollsTable)
        .select()
        .gte('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Vote on poll
  static Future<void> voteOnPoll(String pollId, int optionIndex) async {
    if (currentUser == null) return;
    
    await client.from(SupabaseConfig.pollVotesTable).upsert({
      'poll_id': pollId,
      'user_id': currentUser!.id,
      'option_index': optionIndex,
      'voted_at': DateTime.now().toIso8601String(),
    });
  }

  // ============ DAILY MESSAGES ============

  /// Get today's daily message
  static Future<Map<String, dynamic>?> getDailyMessage() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final response = await client
        .from(SupabaseConfig.dailyMessagesTable)
        .select()
        .eq('date', today)
        .maybeSingle();
    
    return response;
  }

  // ============ COUNTDOWN ============

  /// Get upcoming countdown events
  static Future<List<Map<String, dynamic>>> getCountdownEvents() async {
    final response = await client
        .from(SupabaseConfig.countdownTable)
        .select()
        .gte('event_date', DateTime.now().toIso8601String())
        .order('event_date', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // ============ LEADERBOARD ============

  /// Get leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 100}) async {
    final response = await client
        .from(SupabaseConfig.leaderboardTable)
        .select('*, users(username, bias)')
        .order('points', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Update user points
  static Future<void> addPoints(int points) async {
    if (currentUser == null) return;
    
    await client.rpc('add_user_points', params: {
      'user_id': currentUser!.id,
      'points_to_add': points,
    });
  }

  // ============ REALTIME ============

  /// Subscribe to theories updates
  static RealtimeChannel subscribeToTheories(void Function(Map<String, dynamic>) onData) {
    return client
        .channel('public:theories')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.theoriesTable,
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }

  /// Unsubscribe from channel
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
