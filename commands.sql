-- REQUIRED COMMAND 1: adds new password entry into passwords db across all tables
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS PASSWORD_ENTRY (
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

  -- NO 'IGNORE' intentionally returns error and aborts the procedure call to ensure user knows entry not added
  INSERT INTO password
  (email_address, url, encrypted_password, user_name, timestamp, comment)
  VALUES (
    email_address,
    url,
    AES_ENCRYPT(password,@key_str, @init_vector),
    user_name,
    CURRENT_TIMESTAMP,
    IFNULL(comment, DEFAULT(password.comment)) -- if 'NULL' passed, reverts to default value
  );
END//



-- REQUIRED COMMAND 2: Retrieves a plain text password from a given user email and url
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

DELIMITER ;
