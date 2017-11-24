defmodule Memento.API.Pagination do
  @default_per_page 20

  def parse(qs_params) do
    page = parse(qs_params, "page", 1)
    per_page = parse(qs_params, "per_page", @default_per_page)

    to_limit_and_offset(page, per_page)
  end

  def parse(qs_params, key, default) do
    qs_params
    |> Map.get(key)
    |> sanitize
    |> ok_or_default(default)
  end

  defp to_limit_and_offset(page, per_page) do
    offset = (page - 1) * per_page

    {per_page, offset}
  end

  defp sanitize(v) when is_binary(v) do
    case Integer.parse(v) do
      {int, _} -> {:ok, int}
      error -> error
    end
  end

  defp sanitize(v) when is_integer(v), do: v
  defp sanitize(_v), do: :error

  defp ok_or_default({:ok, v}, _default), do: v
  defp ok_or_default(:error, default), do: default
end
