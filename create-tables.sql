CREATE TABLE IF NOT EXISTS user (
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email_address VARCHAR(65) NOT NULL,
  PRIMARY KEY (email_address)
);

CREATE TABLE IF NOT EXISTS website (
  site_name VARCHAR(100) NOT NULL,
  url VARCHAR(256) NOT NULL,
  PRIMARY KEY (url)
);

CREATE TABLE IF NOT EXISTS password(
  email_address VARCHAR(65) NOT NULL,
  url VARCHAR(256) NOT NULL,
  encrypted_password VARBINARY(256) NOT NULL,
  user_name VARCHAR(65) NOT NULL,
  timestamp TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  comment VARCHAR(1000),
  PRIMARY KEY (email_address,url),
  FOREIGN KEY (email_address) REFERENCES user (email_address),
  FOREIGN KEY (url) REFERENCES website (url),
  UNIQUE (encrypted_password)
);
