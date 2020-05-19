defmodule Memento.Entry do
  alias Memento.{Entry.Query, Repo, Schema.Entry}

  def search(%{q: q, type: type, page: page, per_page: per_page}) do
    limit = per_page
    offset = (page - 1) * per_page

    query = Query.ordered_by_saved_at_desc(Entry, limit, offset)

    with_filters_query =
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

    Repo.all(with_filters_query)
  end
end
