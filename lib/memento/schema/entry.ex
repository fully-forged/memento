defmodule Memento.Schema.Entry do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "entries" do
    field(:type, Memento.Schema.Entry.Type)
    field(:content, :map)
    field(:saved_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end
end
