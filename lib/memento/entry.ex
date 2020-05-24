defmodule Memento.Entry do
  alias Memento.{Entry.Query, Repo, Schema.Entry}

  def search(%{q: q, type: type, page: page, per_page: per_page}) do
    limit = per_page
    offset = (page - 1) * per_page

    query =
      Entry
      |> Query.ordered_by_saved_at_desc(limit, offset)
      |> apply_filters(type, q)

    Repo.all(query)
  end

  def count(%{q: q, type: type}) do
    query = apply_filters(Entry, type, q)

    Repo.aggregate(query, :count, :id)
  end

  defp apply_filters(query, type, q) do
    case {q, type} do
      {:not_provided, :all} ->
        query

      {q, :all} when is_binary(q) ->
        if String.length(q) >= 3 do
          prefix_q = q <> ":*"
          Query.search(query, prefix_q)
        else
          query
        end

      {q, type} when is_binary(q) ->
        if String.length(q) >= 3 do
          prefix_q = q <> ":*"

          query
          |> Query.by_type(type)
          |> Query.search(prefix_q)
        else
          Query.by_type(query, type)
        end

      {_q, type} ->
        Query.by_type(query, type)
    end
  end
end
