-- Create User table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  fullname VARCHAR(120) NOT NULL,
  phone_number VARCHAR(20),
  email VARCHAR(200) UNIQUE NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('tenant', 'landlord')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  image_profile_url VARCHAR(500),
  previous_visitor_id UUID,
  id_card_url VARCHAR(500),
  verify_status VARCHAR(20) DEFAULT 'pending' CHECK (verify_status IN ('pending', 'verified', 'default')),
  selfie_url VARCHAR(500),
  FOREIGN KEY (previous_visitor_id) REFERENCES visitors(id) ON DELETE SET NULL,
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Users are viewable by everyone" ON users;

-- Create proper RLS policies
CREATE POLICY "Users can insert own record"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can read own record"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own record"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can read all users"
  ON users FOR SELECT
  TO authenticated
  USING (true);
