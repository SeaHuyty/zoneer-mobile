-- Create Amenity Table
CREATE TABLE IF NOT EXISTS amenities(
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	name VARCHAR(120) UNIQUE
);

-- Enable Row Level Security
ALTER TABLE amenities ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Amenities are viewable by everyone"
	ON amenities FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.