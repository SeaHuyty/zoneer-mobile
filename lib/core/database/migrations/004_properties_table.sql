-- Create Property Table
CREATE TABLE IF NOT EXISTS properties(
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	price DECIMAL(10, 2) NOT NULL,
	bedroom INT NOT NULL,
	bathroom INT NOT NULL,
	square_area DECIMAL(10, 2) NOT NULL,
	address VARCHAR(255) NOT NULL,
	location_url VARCHAR(500) NOT NULL,
	description TEXT,
	security_features JSON,
	property_features JSON,
	badge_options JSON,
	verify_status VARCHAR(20) DEFAULT 'default' CHECK (verify_status IN ('default', 'pending', 'verified')),
	property_status VARCHAR(20) DEFAULT 'available' CHECK (property_status IN ('rented', 'available')),
	landlord_id UUID NOT NULL,
	verified_by_admin UUID NOT NULL,
	FOREIGN KEY (landlord_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (verified_by_admin) REFERENCES admins(id) ON DELETE SET NULL
);

-- Enable Row Level Security
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "Properties are viewable by everyone"
	ON properties FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.