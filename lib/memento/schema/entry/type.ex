defmodule Memento.Schema.Entry.Type do
  @moduledoc false
  use Ecto.Type

  @valid_types [
    :twitter_fav,
    :pinboard_link,
    :github_star,
    :instapaper_bookmark
  ]

  @type t :: :twitter_fav | :pinboard_link | :github_star | :instapaper_bookmark

  @spec constraint_opts :: Keyword.t()
  def constraint_opts do
    [name: "entry_type"]
  end

  @spec type_strings :: [String.t()]
  def type_strings do
    Enum.map(@valid_types, &Atom.to_string/1)
  end

  @spec type :: :string
  def type, do: :string

  @spec cast(t) :: {:ok, t} | :error
  def cast(type) when type in @valid_types do
    {:ok, type}
  end

  def cast(_), do: :error

  @spec load(String.t()) :: {:ok, t}
  def load(type) do
    {:ok, String.to_existing_atom(type)}
  end

  @spec dump(t) :: {:ok, String.t()}
  def dump(type) do
    {:ok, Atom.to_string(type)}
  end
end
