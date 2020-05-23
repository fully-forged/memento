defmodule MementoWeb.QsParamsValidator do
  @default_page 1
  @default_per_page 25
  @default_type :all

  @moduledoc """
  This module validates and parses a map with string keys representing a query string
  and returns a stable map that can be used with database queries.

  When the params map doesn't have necessary keys, defaults are provided.

  Defaults:

  - `page`: `#{@default_page}`
  - `per_page`: `#{@default_per_page}`
  - `type`: `#{@default_type}`
  """

  alias Memento.Schema.Entry

  @type params :: %{
          page: pos_integer(),
          per_page: pos_integer(),
          type: :all | Entry.Type.t(),
          q: String.t() | :not_provided
        }

  @doc """
  Validates a map with binary keys, returning either `{:ok, map_with_atom_keys}` or
  `{:error, reason}`, where the returned map has a predictable structure.

      iex> alias MementoWeb.QsParamsValidator, as: V
      iex> V.validate(%{"page" => "10"})
      {:ok, %{page: 10, per_page: 25, q: :not_provided, type: :all}}
  """
  @spec validate(%{optional(String.t()) => term}) ::
          {:ok, params} | {:error, term}
  def validate(qs_params) do
    steps = Saul.all_of([validator(), &transformer/1])
    Saul.validate(qs_params, steps)
  end

  defp validator do
    Saul.map(%{
      "page" => {:optional, &page_validator/1},
      "per_page" => {:optional, &per_page_validator/1},
      "type" => {:optional, &type_validator/1},
      "q" => {:optional, &q_validator/1}
    })
  end

  defp transformer(map) do
    result = %{
      page: Map.get(map, "page", @default_page),
      per_page: Map.get(map, "per_page", @default_per_page),
      type: Map.get(map, "type", @default_type),
      q: Map.get(map, "q", :not_provided)
    }

    {:ok, result}
  end

  defp page_validator(page), do: string_to_integer(page)

  defp per_page_validator(per_page), do: string_to_integer(per_page)

  defp string_to_integer(string) do
    case Integer.parse(string) do
      {int, ""} -> {:ok, int}
      _other -> {:error, "not parsable as integer"}
    end
  end

  defp type_validator("all") do
    {:ok, :all}
  end

  defp type_validator(type_string) do
    if type_string in Entry.Type.type_strings() do
      Entry.Type.load(type_string)
    else
      {:error, "invalid type string"}
    end
  end

  defp q_validator(q) do
    is_binary(q)
  end
end
