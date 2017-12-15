defmodule Memento.Repo.Migrations.AddInstapaperBookmarkEntryType do
  use Ecto.Migration
  # The following module attribute needs to be set to allow the migration
  # execution outside a transaction (it's not possible to modify an enum
  # in Postgres inside a transaction block).
  @disable_ddl_transaction true

  def up do
    execute(
      "ALTER TYPE entry_type ADD VALUE 'instapaper_bookmark' AFTER 'github_star'"
    )
  end

  def down do
    execute("""
    DELETE from entries
    WHERE entries.type = 'instapaper_bookmark'
    """)

    execute("""
    DELETE FROM pg_enum
    WHERE enumlabel = 'instapaper_bookmark'
    AND enumtypid = (
      SELECT oid FROM pg_type WHERE typname = 'entry_type'
    )
    """)
  end
end
