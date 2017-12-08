defmodule Memento.Repo.Migrations.AddFunctionToRefreshEntriesSearchIndex do
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR replace FUNCTION refresh_entries_search_index
      () returns TRIGGER LANGUAGE plpgsql
    AS
      $$
    BEGIN
      refresh materialized VIEW entries_search_index;
      RETURN NULL;
    END $$;
    """)

    execute("""
    CREATE TRIGGER refresh_entries_search_index AFTER
    INSERT OR UPDATE OR DELETE OR TRUNCATE
    ON entries FOR EACH STATEMENT
    EXECUTE PROCEDURE refresh_entries_search_index()
    """)
  end

  def down do
    execute("""
    DROP TRIGGER refresh_entries_search_index ON entries
    """)

    execute("""
    DROP FUNCTION refresh_entries_search_index()
    """)
  end
end
