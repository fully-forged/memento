defmodule Memento.Schema.Entry.SearchIndex do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "entries_search_index" do
    field(:text, :string)
  end
end
