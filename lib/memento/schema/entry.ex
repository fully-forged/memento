defmodule Memento.Schema.Entry do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "entries" do
    field(:type, Memento.Schema.Entry.Type)
    field(:content, :map)
    field(:saved_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  defimpl Poison.Encoder do
    def encode(entry, opts) do
      entry
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Poison.encode!(opts)
    end
  end
end
