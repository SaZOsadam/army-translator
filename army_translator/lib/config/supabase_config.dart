class SupabaseConfig {
  static const String supabaseUrl = 'https://zcivfmgmfxqsqukoygcn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjaXZmbWdtZnhxc3F1a295Z2NuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyMjU1MDAsImV4cCI6MjA4NjgwMTUwMH0.cWMqEuULam2MabTzs9rVSyb4MKTcCmqjTpQkXyAYYHk';
  
  // Deep link configuration for OAuth
  static const String redirectUrl = 'com.armyapps.armytranslator://login-callback';
  
  // Table names
  static const String usersTable = 'users';
  static const String sessionsTable = 'translation_sessions';
  static const String subtitlesTable = 'subtitles';
  static const String userStatsTable = 'user_stats';
}
