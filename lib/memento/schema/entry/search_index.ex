defmodule Memento.Schema.Entry.SearchIndex do
  @moduledoc """
  The search index is a read-only schema backed by
  a materialized view that is kept automatically in sync
  with the content of the entries table.

  Each row is composed by an entry id and a full-text searchable
  representation of that entry.
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  @type t :: %__MODULE__{
          __meta__: %Ecto.Schema.Metadata{},
          id: String.t(),
          text: String.t()
        }

  schema "entries_search_index" do
    field(:text, :string)
  end
end
