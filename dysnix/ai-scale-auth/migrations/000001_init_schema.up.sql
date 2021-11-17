BEGIN;

CREATE TABLE IF NOT EXISTS "clients" (
  "id" bigserial PRIMARY KEY,
  "name" varchar NOT NULL UNIQUE,
  "cluster_id" UUID NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "updated_at" timestamptz NOT NULL DEFAULT (now()),
  "deleted_at" timestamptz
);

CREATE TABLE IF NOT EXISTS "client_keys" (
  "id" bigserial PRIMARY KEY,
  "client_id" bigint NOT NULL,
  "key" bytea NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now()),
  "updated_at" timestamptz NOT NULL DEFAULT (now()),
  "deleted_at" timestamptz
);

ALTER TABLE "client_keys" ADD FOREIGN KEY ("client_id") REFERENCES "clients" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX ON "clients" ("cluster_id");

COMMENT ON COLUMN "client_keys"."key" IS 'must be not empty';

COMMIT;