insert into visitors (device_id)
values
  ('device_001'),
  ('device_002'),
  ('device_003');


insert into admins (username, password, email)
values
  ('Admin One', 'password123', 'admin1@test.com'),
  ('Admin Two', 'password123', 'admin2@test.com');

-- Link some users to previous visitors
insert into users (id, fullname, phone_number, email, role, previous_visitor_id, verify_status, image_profile_url)
select gen_random_uuid(), 'Alice Tenant', '08123456789', 'alice@test.com', 'tenant', id, 'verified', 'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(5).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICg1KS5qcGciLCJpYXQiOjE3NzA1NDAwNDQsImV4cCI6MTgwMjA3NjA0NH0.YU3Q1l40rJ4NyAdgbBbsuR91U9TN9k9nMg0gBU3HO88'
from visitors
where device_id = 'device_001';

insert into users (id, fullname, phone_number, email, role, previous_visitor_id, image_profile_url)
select gen_random_uuid(), 'Bob Landlord', '08129876543', 'bob@test.com', 'landlord', id, 'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(5).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICg1KS5qcGciLCJpYXQiOjE3NzA1NDAwNDQsImV4cCI6MTgwMjA3NjA0NH0.YU3Q1l40rJ4NyAdgbBbsuR91U9TN9k9nMg0gBU3HO88'
from visitors
where device_id = 'device_002';

-- Insert a new user without linking to a visitor
insert into users (id, fullname, phone_number, email, role, image_profile_url)
values
  (gen_random_uuid(), 'Charlie Tenant', '08121112222', 'charlie@test.com', 'tenant', 'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(5).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICg1KS5qcGciLCJpYXQiOjE3NzA1NDAwNDQsImV4cCI6MTgwMjA3NjA0NH0.YU3Q1l40rJ4NyAdgbBbsuR91U9TN9k9nMg0gBU3HO88');

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
SELECT
  1200.00,
  2,
  1,
  75.5,
  '123 Main St, City',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Cozy apartment near downtown',
  '{"cctv": true, "security_guard": true}'::json,
  '{"wifi": true, "balcony": true}'::json,
  '{"featured": true}'::json,
  'verified',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(1).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgxKS5qcGciLCJpYXQiOjE3NzAyNjU2NDAsImV4cCI6MTgwMTgwMTY0MH0.IkHHCty_6n1AMl_0j3czN_a-glZN0v_3XWAL8ZArjiQ',
  admin_id
FROM landlord, admin

UNION ALL

SELECT
  2000.00,
  3,
  2,
  120.0,
  '456 Elm St, City',
  'https://maps.app.goo.gl/8ersyZjBAY1A2DK67',
  'Spacious house with garden',
  '{"cctv": true, "security_guard": false}'::json,
  '{"wifi": true, "balcony": true, "pool": true}'::json,
  '{"featured": false}'::json,
  'pending',
  'available',
  landlord_id,
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(2).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgyKS5qcGciLCJpYXQiOjE3NzAyNjU3OTAsImV4cCI6MTgwMTgwMTc5MH0.hxduERFqL0PChvarUdZjaJtN68Wt25tsZEYfgTybKzc',
  admin_id
FROM landlord, admin;


-- Link media to properties
INSERT INTO media (url, property_id)
SELECT
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(3).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICgzKS5qcGciLCJpYXQiOjE3NzAyNjU4MDAsImV4cCI6MTgwMTgwMTgwMH0.9QRXuLG1GX6KagscF0Qrv8n718Zn1dypL7HwBavk-qw',
  id
FROM properties
LIMIT 1;

INSERT INTO media (url, property_id)
SELECT
  'https://wpxbpemkvlnrnxosfqzn.supabase.co/storage/v1/object/sign/properties_image/download%20(4).jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9kNDAyOTZkNy1lZjMwLTQ2MGItYWY1My1hZTk2NjdlNjQ1YmEiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9wZXJ0aWVzX2ltYWdlL2Rvd25sb2FkICg0KS5qcGciLCJpYXQiOjE3NzAyNjU4MTcsImV4cCI6MTgwMTgwMTgxN30.pl_MBmDw1V4dQG4N-LSb3jmiyuBK3ZifpAsqJU0nyt0',
  id
FROM properties
OFFSET 1
LIMIT 1;


-- Alice wishes for the first property
insert into wishlists (user_id, property_id)
select u.id, p.id
from users u, properties p
where u.fullname = 'Alice Tenant'
limit 1;


insert into notifications (user_id, title, message, notification_type)
select id, 'Welcome!', 'Your account has been created.', 'system'
from users;


insert into inquiries (property_id, user_id, fullname, email, phone_number, message)
select p.id, u.id, u.fullname, u.email, u.phone_number, 'I am interested in this property, please provide more info.'
from properties p, users u
where u.fullname = 'Charlie Tenant'
limit 1;
