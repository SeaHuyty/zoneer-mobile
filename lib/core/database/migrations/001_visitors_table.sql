-- Create Visitor table
CREATE TABLE IF NOT EXISTS visitors (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	device_id VARCHAR(255),
	last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
	created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;

-- Create Policy
CREATE POLICY "Visitors are viewable by everyone"
	ON visitors FOR SELECT
	USING (true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.