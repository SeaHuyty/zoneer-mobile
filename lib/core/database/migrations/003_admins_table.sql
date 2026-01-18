-- Create Admin Table
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	username VARCHAR(120) NOT NULL,
	password VARCHAR(255) NOT NULL,
	email VARCHAR(200) UNIQUE NOT NULL,
	image_profile_url VARCHAR(500)
);

-- Enable Row Level Security
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Admins are viewable by everyone"
	ON admins FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.