defmodule Memento.Repo.Migrations.AddFullTextIndexOnEntries do
  use Ecto.Migration

  def change do
    execute("""
    CREATE INDEX content_full_text_idx
    ON entries
    USING gin (to_tsvector('english', content));
    """)

    execute("""
    DROP TRIGGER refresh_entries_search_index ON entries;
    """)

    execute("""
    DROP FUNCTION refresh_entries_search_index();
    """)

    execute("""
    DROP MATERIALIZED VIEW entries_search_index;
    """)
  end
end
