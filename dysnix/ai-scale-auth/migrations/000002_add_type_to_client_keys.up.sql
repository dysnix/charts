BEGIN;

DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'key_type') THEN
            CREATE TYPE key_type AS ENUM ('HS256', 'HS384', 'HS512');
        END IF;
    END
$$;

ALTER TABLE client_keys ADD COLUMN type key_type NOT NULL;

COMMIT;