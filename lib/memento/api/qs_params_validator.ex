defmodule Memento.API.QsParamsValidator do
  @default_per_page 25
  @default_page 1
  @default_type :all

  alias Memento.Schema.Entry

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
