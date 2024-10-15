-- sets encryption mode for DB
-- generates session arguments for AES_Encrypt()
SET block_encryption_mode = 'aes-256-cbc';
SET @key_str = UNHEX(SHA2('encrypt this', 256));
SET @init_vector = RANDOM_BYTES(16);

-- Inserts all unique users for 1st 10 password entries
INSERT INTO user
  (first_name, last_name, email_address)
  VALUES
  ('John', 'Bennett', 'jb@gmail.com'),
  ('Ian','Malcolm', 'ian.malcolm@outlook.com'),
  ('John', 'Bennett', 'johnbennett@hartford.edu'),
  ('Grant', 'Sanderson', 'g.sanderson@3blue1brown.com'),
  ('Josh', 'Johnson', 'jj@joshjohnsoncomedy.com');

-- Inserts all unique websites for 1st 10 password entries
INSERT INTO website
  (site_name, url)
  VALUES
  ('Amazon', 'https://www.amazon.com'),
  ('GitHub', 'https://github.com'),
  ('Premium Oil', 'https://www.ctpremiumoil.com'),
  ('Premium Oil', 'https://www.nypremiumoil.com'),
  ('Spotify', 'https://accounts.spotify.com/'),
  ('LinkedIn', 'https://www.linkedin.com/'),
  ('New York Times', 'https://www.nytimes.com/');

-- Inserts 1st 10 password entries
 INSERT INTO password
    (email_address, url, encrypted_password, user_name)
    VALUES
    ('jb@gmail.com', 'https://github.com', AES_ENCRYPT('sticky putty', @key_str, @init_vector), 'J817B477'),
    ('jb@gmail.com', 'https://www.amazon.com', AES_ENCRYPT('kerosene heater', @key_str, @init_vector), 'John Bennett'),
    ('ian.malcolm@outlook.com', 'https://www.nypremiumoil.com', AES_ENCRYPT('chaos theory', @key_str, @init_vector),'Malcolm.I'),
    ('johnbennett@hartford.edu', 'https://www.ctpremiumoil.com', AES_ENCRYPT('sad dinosaur', @key_str, @init_vector), 'John Bennett'),
    ('johnbennett@hartford.edu', 'https://accounts.spotify.com/', AES_ENCRYPT('rebel music', @key_str, @init_vector), 'J477'),
    ('g.sanderson@3blue1brown.com', 'https://github.com', AES_ENCRYPT('math in motion', @key_str, @init_vector), '3b1b'),
    ('g.sanderson@3blue1brown.com', 'https://accounts.spotify.com/', AES_ENCRYPT('math is music', @key_str, @init_vector), '3b1b'),
    ('g.sanderson@3blue1brown.com', 'https://www.linkedin.com/', AES_ENCRYPT('free conferences', @key_str, @init_vector), 'Grant Sanderson'),
    ('jj@joshjohnsoncomedy.com', 'https://www.nytimes.com/', AES_ENCRYPT('not funny material', @key_str, @init_vector), 'J.Johnson'),
    ('jj@joshjohnsoncomedy.com', 'https://www.linkedin.com/', AES_ENCRYPT('comedy business b', @key_str, @init_vector), 'Josh Johnson Comedy');
