defmodule Memento.Schema.Entry do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(initial, attrs \\ %{}) do
    initial
    |> cast(attrs, [:type, :content, :saved_at])
    |> unique_constraint(
         :content,
         name: :type_and_json_id_idx,
         message: "references an already existing id for this type"
       )
  end
end
