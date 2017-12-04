defmodule Memento.API.Pagination do
  @default_per_page 20

  @type limit :: non_neg_integer
  @type offset :: non_neg_integer

  @doc """
  Extracts pagination values out of a query string params map (with string keys) and returns
  a tuple with limit and offset, ready to be passet to an Ecto query.

  Returns default values when keys are absent or their value cannot be parse to an int.

  Expected keys are `page` (default 1) and `per_page` (default #{
    @default_per_page
  }).

      iex> alias Memento.API.Pagination
      iex> Pagination.parse(%{})
      {20, 0}
      iex> Pagination.parse(%{"page" => "2", "per_page" => 50})
      {50, 50}
      iex> Pagination.parse(%{"page" => "not-a-number", "per_page" => "50"})
      {50, 0}
  """
  @spec parse(Map.t()) :: {limit, offset}
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

  defp sanitize(v) when is_integer(v), do: {:ok, v}
  defp sanitize(_v), do: :error

  defp ok_or_default({:ok, v}, _default), do: v
  defp ok_or_default(:error, default), do: default
end
