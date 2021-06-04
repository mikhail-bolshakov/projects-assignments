ALTER TABLE test_mb.bi_assignment_account ADD CONSTRAINT fk_account_person FOREIGN KEY (id_person) REFERENCES test_mb.bi_assignment_person (id);
ALTER TABLE test_mb.bi_assignment_transaction ADD CONSTRAINT fk_transaction_account FOREIGN KEY (id_account) REFERENCES test_mb.bi_assignment_account (id);
