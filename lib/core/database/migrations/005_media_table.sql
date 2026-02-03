-- Create Media Table
CREATE TABLE IF NOT EXISTS media(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url TEXT NOT NULL,
  property_id UUID,
  FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE media ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Media are viewable by everyone"
	ON media FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.