-- Create Notification Table
CREATE TABLE IF NOT EXISTS notifications(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(100) DEFAULT 'system'
    CHECK (notification_type IN (
      'property_verification', 
      'tenant_verification', 
      'landlord_verification',
      'transaction',
      'system',
      'inquiry_response',
      'reminder')
    ),
  is_read BOOLEAN DEFAULT false,
  meta_data JSON,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Notifications are viewable by everyone"
	ON notifications FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.