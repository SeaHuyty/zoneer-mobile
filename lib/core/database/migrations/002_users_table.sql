-- Create User table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fullname VARCHAR(120) NOT NULL,
  phone_number VARCHAR(20),
  email VARCHAR(200) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('tenant', 'landlord')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  image_profile_url VARCHAR(500),
  previous_visitor_id UUID,
  id_card_url VARCHAR(500),
  verify_status VARCHAR(20) DEFAULT 'default' CHECK (verify_status IN ('pending', 'verified', 'default')),
  selfie_url VARCHAR(500),
  FOREIGN KEY (previous_visitor_id) REFERENCES visitors(id) ON DELETE SET NULL
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Users are viewable by everyone" 
  ON users FOR SELECT 
  USING (true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.
