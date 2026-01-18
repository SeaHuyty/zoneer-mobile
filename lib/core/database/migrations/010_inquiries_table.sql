-- Create Inquiry Table
CREATE TABLE IF NOT EXISTS inquiries(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID,
  user_id UUID,
  fullname VARCHAR(120) NOT NULL,
  email VARCHAR(200),
  phone_number VARCHAR(20) NOT NULL,
  occupation VARCHAR(255),
  message TEXT NOT NULL,
  status VARCHAR(30) DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'closed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Inquiries are viewable by everyone"
	ON inquiries FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.