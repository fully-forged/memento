defmodule Memento.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE entry_type AS ENUM ('twitter_fav', 'pinboard_link', 'github_star')")

    create table(:entries, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :entry_type, null: false)
      add(:content, :map)
      add(:saved_at, :utc_datetime)

      timestamps()
    end
  end

  def down do
    drop(table(:entries))

    execute("DROP TYPE entry_type")
  end
end
