-- =============================================
-- SUPABASE DATABASE SETUP FOR ARMY APPS
-- Run this in Supabase SQL Editor
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- SHARED TABLES (Both Apps)
-- =============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  username TEXT,
  bias TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =============================================
-- ARMY HUB TABLES
-- =============================================

-- Theories table
CREATE TABLE IF NOT EXISTS theories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  prompt TEXT,
  tags TEXT[] DEFAULT '{}',
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE theories ENABLE ROW LEVEL SECURITY;

-- Anyone can read theories
CREATE POLICY "Anyone can view theories" ON theories
  FOR SELECT USING (true);

-- Users can create their own theories
CREATE POLICY "Users can create theories" ON theories
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own theories
CREATE POLICY "Users can update own theories" ON theories
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own theories
CREATE POLICY "Users can delete own theories" ON theories
  FOR DELETE USING (auth.uid() = user_id);

-- Polls table
CREATE TABLE IF NOT EXISTS polls (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE polls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view polls" ON polls
  FOR SELECT USING (true);

-- Poll votes table
CREATE TABLE IF NOT EXISTS poll_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  poll_id UUID REFERENCES polls(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  option_index INTEGER NOT NULL,
  voted_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(poll_id, user_id)
);

ALTER TABLE poll_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can vote" ON poll_votes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view votes" ON poll_votes
  FOR SELECT USING (true);

-- Daily messages table
CREATE TABLE IF NOT EXISTS daily_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE UNIQUE NOT NULL,
  member TEXT NOT NULL,
  message_kr TEXT NOT NULL,
  message_en TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE daily_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view daily messages" ON daily_messages
  FOR SELECT USING (true);

-- Countdown events table
CREATE TABLE IF NOT EXISTS countdown_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMPTZ NOT NULL,
  image_url TEXT,
  event_type TEXT DEFAULT 'general',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE countdown_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view countdown events" ON countdown_events
  FOR SELECT USING (true);

-- Leaderboard table
CREATE TABLE IF NOT EXISTS leaderboard (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  points INTEGER DEFAULT 0,
  theories_count INTEGER DEFAULT 0,
  rank INTEGER,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view leaderboard" ON leaderboard
  FOR SELECT USING (true);

CREATE POLICY "Users can update own leaderboard" ON leaderboard
  FOR UPDATE USING (auth.uid() = user_id);

-- =============================================
-- ARMY TRANSLATOR TABLES
-- =============================================

-- Translation sessions table
CREATE TABLE IF NOT EXISTS translation_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  duration INTEGER DEFAULT 0,
  line_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE translation_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions" ON translation_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create sessions" ON translation_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions" ON translation_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- Subtitles table
CREATE TABLE IF NOT EXISTS subtitles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES translation_sessions(id) ON DELETE CASCADE NOT NULL,
  timestamp INTEGER NOT NULL,
  original_text TEXT NOT NULL,
  translated_text TEXT NOT NULL,
  speaker TEXT,
  confidence REAL DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE subtitles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subtitles" ON subtitles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM translation_sessions 
      WHERE translation_sessions.id = subtitles.session_id 
      AND translation_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create subtitles" ON subtitles
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM translation_sessions 
      WHERE translation_sessions.id = subtitles.session_id 
      AND translation_sessions.user_id = auth.uid()
    )
  );

-- User stats table
CREATE TABLE IF NOT EXISTS user_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  total_sessions INTEGER DEFAULT 0,
  total_minutes INTEGER DEFAULT 0,
  total_lines INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own stats" ON user_stats
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON user_stats
  FOR UPDATE USING (auth.uid() = user_id);

-- =============================================
-- FUNCTIONS
-- =============================================

-- Function to increment theory likes
CREATE OR REPLACE FUNCTION increment_likes(theory_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE theories 
  SET likes = likes + 1 
  WHERE id = theory_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add user points
CREATE OR REPLACE FUNCTION add_user_points(p_user_id UUID, points_to_add INTEGER)
RETURNS VOID AS $$
BEGIN
  INSERT INTO leaderboard (user_id, points, theories_count)
  VALUES (p_user_id, points_to_add, 0)
  ON CONFLICT (user_id)
  DO UPDATE SET 
    points = leaderboard.points + points_to_add,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats(
  p_user_id UUID,
  p_sessions INTEGER,
  p_minutes INTEGER,
  p_lines INTEGER
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_stats (user_id, total_sessions, total_minutes, total_lines)
  VALUES (p_user_id, p_sessions, p_minutes, p_lines)
  ON CONFLICT (user_id)
  DO UPDATE SET 
    total_sessions = user_stats.total_sessions + p_sessions,
    total_minutes = user_stats.total_minutes + p_minutes,
    total_lines = user_stats.total_lines + p_lines,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SAMPLE DATA (Optional)
-- =============================================

-- Insert a sample countdown event
INSERT INTO countdown_events (title, description, event_date, event_type)
VALUES (
  'BTS ARIRANG Comeback',
  'The new era begins! 💜',
  '2026-06-13 00:00:00+00',
  'comeback'
) ON CONFLICT DO NOTHING;

-- Insert a sample daily message
INSERT INTO daily_messages (date, member, message_kr, message_en)
VALUES (
  CURRENT_DATE,
  'BTS',
  '아미 사랑해요! 💜',
  'ARMY, we love you! 💜'
) ON CONFLICT (date) DO NOTHING;
