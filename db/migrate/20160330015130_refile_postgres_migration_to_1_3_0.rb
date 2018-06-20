class RefilePostgresMigrationTo130 < ActiveRecord::Migration
 def up
   execute <<-SQL
     DROP INDEX index_refile_attachments_on_namespace;
     ALTER TABLE refile_attachments RENAME TO old_refile_attachments;
     ALTER TABLE ONLY old_refile_attachments RENAME CONSTRAINT refile_attachments_pkey TO old_refile_attachments_pkey;
     CREATE TABLE refile_attachments (
       id integer NOT NULL,
       oid oid NOT NULL,
       namespace character varying NOT NULL,
       created_at timestamp without time zone DEFAULT ('now'::text)::timestamp without time zone
     );
     ALTER TABLE ONLY refile_attachments ADD CONSTRAINT refile_attachments_pkey PRIMARY KEY (id);
     ALTER SEQUENCE refile_attachments_id_seq RESTART OWNED BY refile_attachments.id;
     ALTER TABLE ONLY refile_attachments ALTER COLUMN id SET DEFAULT nextval('refile_attachments_id_seq'::regclass);
     INSERT INTO refile_attachments (oid, namespace) SELECT id, namespace FROM old_refile_attachments;
     CREATE INDEX index_refile_attachments_on_namespace ON refile_attachments USING btree (namespace);
     CREATE INDEX index_refile_attachments_on_oid ON refile_attachments USING btree (oid);
     DROP TABLE old_refile_attachments;
   SQL
 end

 def down
   raise ActiveRecord::IrreversibleMigration
 end
end