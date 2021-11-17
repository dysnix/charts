BEGIN;

ALTER TABLE client_keys DROP COLUMN type;
DROP TYPE key_type;

COMMIT;