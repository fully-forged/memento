defmodule Memento.Repo.Migrations.AddTypeAndJsonIdIndexToEntries do
  use Ecto.Migration

  def change do
    create(
      index(
        "entries",
        [:type, "((content->>'id')::text)"],
        unique: true,
        name: "type_and_json_id_idx"
      )
    )
  end
end

# CREATE UNIQUE INDEX j_uuid_idx ON entries(type, 
