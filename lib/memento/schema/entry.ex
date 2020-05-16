defmodule Memento.Schema.Entry do
  @moduledoc """
  An entry represents an item collected from one of the capture sources.

  The `content` field is a freeform json that should contain an id property.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :type, :content, :saved_at, :inserted_at, :updated_at]}

  @primary_key {:id, :binary_id, autogenerate: true}

  @type content :: %{optional(String.t()) => term}
  @type t :: %__MODULE__{
          __meta__: %Ecto.Schema.Metadata{},
          id: String.t(),
          type: Memento.Schema.Entry.Type.t(),
          content: content,
          saved_at: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "entries" do
    field(:type, Memento.Schema.Entry.Type)
    field(:content, :map)
    field(:saved_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Returns a changeset from an initial entry struct
  and a params map.
  """
  def changeset(initial, attrs \\ %{}) do
    initial
    |> cast(attrs, [:type, :content, :saved_at])
    |> unique_constraint(
      :content,
      name: :type_and_json_id_idx,
      message: "references an already existing id for this type"
    )
  end

  def title(%__MODULE__{type: :github_star, content: content}) do
    Map.get(content, "name")
  end

  def description(%__MODULE__{type: :github_star, content: content}) do
    Map.get(content, "description")
  end

  def url(%__MODULE__{type: :github_star, content: content}) do
    Map.get(content, "url")
  end
end
