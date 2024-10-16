
DELIMITER // -- changes delimiter globally while maintaining it locally

-- COMMAND 1: adds new password entry into passwords db across all tables
CREATE PROCEDURE IF NOT EXISTS PASSWORD_ENTRY(
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email_address VARCHAR(65),
  site_name VARCHAR(100),
  url VARCHAR(256),
  user_name VARCHAR(65),
  password VARCHAR(35),
  comment VARCHAR(1000)
)
BEGIN
  -- 'IGNORE' ensures call perpetuates if duplicate made for PRIMARY KEY
  INSERT IGNORE INTO user
  (first_name, last_name, email_address)
  VALUES
  (first_name, last_name, email_address);

  INSERT IGNORE INTO website
  (site_name, url)
  VALUES
  (site_name, url);

  -- NO 'IGNORE' intentionally returns error and aborts the procedure call to ensure
  -- user knows entry not added in case of PRIMARY KEY duplicates
  INSERT INTO password
  (email_address, url, encrypted_password, user_name, timestamp, comment)
  VALUES (
    email_address,
    url,
    AES_ENCRYPT(password,@key_str, @init_vector),
    user_name,
    CURRENT_TIMESTAMP,
    comment
  );
END//

-- COMMAND 2: Retrieves a plain text password from a given user email and url
-- because there are multiple users and therefore multiple of the
-- url for different users, I used both parameters (as they define the primary key)
CREATE PROCEDURE IF NOT EXISTS RETRIEVE_PASSWORD(
  email_address VARCHAR(65),
  url VARCHAR(256)
)
BEGIN
  SELECT CAST(AES_DECRYPT(encrypted_password, @key_str, @init_vector) AS CHAR)
  AS 'Plain Text Password'
  FROM password
  WHERE password.email_address = email_address AND password.url = url;
END//


-- COMMAND 3: Retrieves all password information about URLs that contain 'https'
-- in 2 of the initial 10 entries
CREATE PROCEDURE IF NOT EXISTS RETRIEVE_2HTTPS()
BEGIN
  SELECT site_name,
          url,
          first_name,
          last_name,
          email_address,
          CAST(AES_DECRYPT(encrypted_password, @key_str, @init_vector) AS CHAR)
          AS 'Plain Text Password',
          timestamp,
          comment
  FROM user
  INNER JOIN password USING (EMAIL_ADDRESS)
  INNER JOIN website USING (url)
  WHERE upper(URL) LIKE UPPER('https%')
  LIMIT 2;
END//


-- COMMAND 4: Changes a URL associated with one of the passwords in the initial 10 entries
CREATE PROCEDURE IF NOT EXISTS UPDATE_PASSWORD_URL(
  password VARCHAR(35),
  new_url VARCHAR(256),
  site_name VARCHAR(100)
)
BEGIN
  INSERT IGNORE INTO website
  (site_name, url)
  VALUES
  (site_name, new_url);

  UPDATE password SET url = new_url
  WHERE encrypted_password = AES_ENCRYPT(password, @key_str, @init_vector);
END//

-- COMMAND 5: Changes any password
CREATE PROCEDURE IF NOT EXISTS CHANGE_PASSWORD(
  old_password VARCHAR(35),
  new_password VARCHAR(35)
)
BEGIN
  UPDATE password SET encrypted_password = AES_ENCRYPT(new_password, @key_str, @init_vector)
  WHERE encrypted_password = AES_ENCRYPT(old_password, @key_str, @init_vector);
END//

-- COMMAND 6: Removes a tuple based one of a specific user's saved URLs
CREATE PROCEDURE IF NOT EXISTS REMOVE_URL(
  user_email VARCHAR(65),
  site_url VARCHAR(256)
)
BEGIN
  DELETE
  FROM password
  WHERE email_address = user_email AND url = site_url;

  -- 'IGNORE' ensures that procedure will run even if foreign key constraint violated
  -- (which is still prevented from happening)
  DELETE IGNORE
  FROM  website
  WHERE url = site_url;
END//

-- Command 7: Removes a tuple based on a password
CREATE PROCEDURE IF NOT EXISTS REMOVE_PASSWORD(
  user_email VARCHAR(65),
  current_password VARCHAR(35)
)
BEGIN
  -- the temp_url variable is used to remove the url from 'website' relation if it no longer
  -- exists in the password relation
  -- ('user' relation remains the same based on assumption user not quitting password service)
  DECLARE temp_url VARCHAR(256);
  SELECT url INTO temp_url
  FROM password
  WHERE email_address = user_email AND encrypted_password = AES_ENCRYPT(current_password, @key_str, @init_vector);

  DELETE
  FROM password
  WHERE email_address = user_email AND encrypted_password = AES_ENCRYPT(current_password, @key_str, @init_vector);

  DELETE IGNORE
  FROM  website
  WHERE url = temp_url;
END//

DELIMITER ; -- changes delimiter back to ";"
