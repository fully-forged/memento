defmodule Memento.Repo.Migrations.CreateEntriesSearchIndexView do
  use Ecto.Migration

  def up do
    execute("""
    CREATE MATERIALIZED VIEW entries_search_index AS
    SELECT id,
      CASE WHEN type='twitter_fav' THEN (content ->> 'screen_name') || (content ->> 'text')
           WHEN type='github_star' THEN (content ->> 'owner') || (content ->> 'name') || (content ->> 'description')
           WHEN type='pinboard_link' THEN (content ->> 'description')
           ELSE ''
      END AS text
    FROM entries
    """)

    execute("""
    CREATE INDEX idx_flat_text
    ON entries_search_index
    USING gin(to_tsvector('english', text));
    """)
  end

  def down do
    execute("""
    DROP MATERIALIZED VIEW entries_search_index
    """)
  end
end
