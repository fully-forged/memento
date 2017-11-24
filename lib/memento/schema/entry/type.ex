defmodule Memento.Schema.Entry.Type do
  @behaviour Ecto.Type

  @valid_types [:twitter_fav, :pinboard_link, :github_star]

  @type type :: :twitter_fav | :pinboard_link | :github_star

  @spec constraint_opts :: Keyword.t()
  def constraint_opts do
    [name: "entry_type"]
  end

  @spec type :: :string
  def type, do: :string

  @spec cast(type) :: {:ok, type} | :error
  def cast(type) when type in @valid_types do
    {:ok, type}
  end

  def cast(_), do: :error

  @spec load(String.t()) :: {:ok, type}
  def load(type) do
    {:ok, String.to_existing_atom(type)}
  end

  @spec dump(type) :: {:ok, String.t()}
  def dump(type) do
    {:ok, Atom.to_string(type)}
  end
end
