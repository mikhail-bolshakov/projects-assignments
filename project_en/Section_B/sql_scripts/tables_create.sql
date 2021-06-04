CREATE SCHEMA IF NOT EXISTs test_mb;
DROP TABLE IF EXISTS test_mb.bi_assignment_account CASCADE;
CREATE TABLE test_mb.bi_assignment_account 
(
  id_account     INT,
  id_person      INT,
  account_type   VARCHAR(64)
);
DROP TABLE IF EXISTS test_mb.bi_assignment_person CASCADE;
CREATE TABLE test_mb.bi_assignment_person 
(
  id_person      INT,
  name           VARCHAR(64),
  surname        VARCHAR(255),
  zip            VARCHAR(64),
  city           VARCHAR(64),
  country        VARCHAR(64),
  email          VARCHAR(255),
  phone_number   VARCHAR(64),
  birth_date     DATE
);
DROP TABLE IF EXISTS test_mb.bi_assignment_transaction CASCADE;
CREATE TABLE test_mb.bi_assignment_transaction 
(
  id_transaction     INT,
  id_account         INT,
  transaction_type   VARCHAR(64),
  transaction_date   DATE,
  amount             NUMERIC
);
