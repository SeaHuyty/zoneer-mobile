-- Grab landlord and admin IDs
WITH landlord AS (
  SELECT id AS landlord_id FROM users WHERE fullname = 'Bob Landlord'
),
admin AS (
  SELECT id AS admin_id FROM admins WHERE username = 'Admin One'
)
INSERT INTO properties (
  price,
  bedroom,
  bathroom,
  square_area,
  address,
  location_url,
  description,
  security_features,
  property_features,
  badge_options,
  verify_status,
  property_status,
  landlord_id,
  thumbnail_url,
  verified_by_admin
)

-- Phnom Penh - BKK1
SELECT
  1500.00,
  2,
  2,
  85.0,
  'BKK1, Phnom Penh',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Modern apartment in the heart of BKK1, close to cafes and offices.',
  '{"cctv": true, "security_guard": true}'::json,
  '{"wifi": true, "balcony": true, "parking": true}'::json,
  '{"featured": true}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(1).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgxKS5qcGciLCJpYXQiOjE3NzAyNjQ5MTYsImV4cCI6MTgwMTgwMDkxNn0.dPH1EZYyqbuGqghT2ZMvGJAMqNyuHDoAB9q2nbOsu8M',
  admin_id
FROM landlord, admin

UNION ALL

-- Phnom Penh - Toul Kork
SELECT
  900.00,
  1,
  1,
  55.0,
  'Toul Kork, Phnom Penh',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Affordable condo near universities and supermarkets.',
  '{"cctv": true, "security_guard": false}'::json,
  '{"wifi": true, "elevator": true}'::json,
  '{"featured": false}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkLmpwZyIsImlhdCI6MTc3MDI2NTgzNCwiZXhwIjoxODAxODAxODM0fQ.D2EwpF6FjCaaIc7kzmtjheSZmfuJ2888JlDzMtkYcEM',
  admin_id
FROM landlord, admin

UNION ALL

-- Phnom Penh - Chroy Changvar
SELECT
  1800.00,
  3,
  2,
  130.0,
  'Chroy Changvar, Phnom Penh',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Spacious riverside apartment with city skyline view.',
  '{"cctv": true, "security_guard": true}'::json,
  '{"wifi": true, "balcony": true, "pool": true, "gym": true}'::json,
  '{"featured": true}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkLmpwZyIsImlhdCI6MTc3MDI2NTgzNCwiZXhwIjoxODAxODAxODM0fQ.D2EwpF6FjCaaIc7kzmtjheSZmfuJ2888JlDzMtkYcEM',
  admin_id
FROM landlord, admin

UNION ALL

-- Siem Reap - City Center
SELECT
  700.00,
  1,
  1,
  50.0,
  'City Center, Siem Reap',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Cozy apartment close to Pub Street and Old Market.',
  '{"cctv": true, "security_guard": false}'::json,
  '{"wifi": true, "balcony": true}'::json,
  '{"featured": false}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(4).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICg0KS5qcGciLCJpYXQiOjE3NzAyNjU4NzcsImV4cCI6MTgwMTgwMTg3N30.QOemxd4_hIZ9ZLiuZXMYn9isdMXB9mghi-w7Bc-ne38',
  admin_id
FROM landlord, admin

UNION ALL

-- Siem Reap - Sala Kamreuk
SELECT
  1100.00,
  2,
  2,
  90.0,
  'Sala Kamreuk, Siem Reap',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Quiet residential apartment with modern finishes.',
  '{"cctv": true, "security_guard": true}'::json,
  '{"wifi": true, "parking": true, "garden": true}'::json,
  '{"featured": true}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(1).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgxKS5qcGciLCJpYXQiOjE3NzAyNjU4OTMsImV4cCI6MTgwMTgwMTg5M30.Czk6tL8UPAyS0bi5VlM2ldVYeRnQA4QZk7YWlxHx_tU',
  admin_id
FROM landlord, admin

UNION ALL

-- Siem Reap - Wat Bo
SELECT
  650.00,
  1,
  1,
  48.0,
  'Wat Bo Area, Siem Reap',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Simple and clean apartment near river and cafes.',
  '{"cctv": false, "security_guard": false}'::json,
  '{"wifi": true}'::json,
  '{"featured": false}'::json,
  'pending',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(2).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgyKS5qcGciLCJpYXQiOjE3NzAyNjU5MjYsImV4cCI6MTgwMTgwMTkyNn0.uDpSX6J1Ind0qOyHfr8XPqC81eBe3N0Y3ovxAmooIGw',
  admin_id
FROM landlord, admin;
