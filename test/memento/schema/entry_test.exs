defmodule Memento.Schema.EntryTest do
  use Memento.DbTestCase, async: true

  alias Memento.{Repo, Schema.Entry}

  test "entries are unique per type" do
    attrs = %{type: :twitter_fav, content: %{id: "1"}}
    changeset = Entry.changeset(%Entry{}, attrs)

    {:ok, _} = Repo.insert(changeset)

    assert {:error, _} = Repo.insert(changeset)
  end
end
