-- Create PropertyAmenity Table
CREATE TABLE IF NOT EXISTS property_amenities(
	property_id UUID,
	amenity_id UUID,
	PRIMARY KEY (property_id, amenity_id),
	FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
	FOREIGN KEY (amenity_id) REFERENCES amenities(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE property_amenities ENABLE ROW LEVEL SECURITY;

-- Create policies as needed
CREATE POLICY "PropertyAmenities are viewable by everyone"
	ON property_amenities FOR SELECT
	USING(true);

-- TODO: Create Index for better performance.
-- Only add indexes for columns you frequently filter, join, or sort on.