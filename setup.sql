\W
DROP DATABASE IF EXISTS passwords;

CREATE DATABASE passwords DEFAULT CHARACTER SET utf8mb4;

USE passwords;

source create-tables.sql;
source insert-values.sql;
source commands.sql;
