defmodule Memento.API.EntriesResource do
  use PlugRest.Resource

  alias Memento.{API.QsParamsValidator, Entry.Query, Repo, Schema.Entry}

  def allowed_methods(conn, state) do
    {["GET", "OPTIONS"], conn, state}
  end

  def content_types_provided(conn, state) do
    {[{"application/json", :to_json}], conn, state}
  end

  def to_json(conn, state) do
    {:ok, %{page: page, per_page: per_page, type: type, q: q}} =
      QsParamsValidator.validate(conn.query_params)

    limit = per_page
    offset = (page - 1) * per_page

    query = Query.ordered_by_saved_at_desc(Entry, limit, offset)

    with_filters_query =
      case {q, type} do
        {:not_provided, :all} ->
          query

        {q, type} when is_binary(q) ->
          if String.length(q) >= 3 do
            prefix_q = q <> ":*"
            Query.search(query, prefix_q)
          else
            Query.by_type(query, type)
          end

        {_q, type} ->
          Query.by_type(query, type)
      end

    body =
      with_filters_query
      |> Repo.all()
      |> Poison.encode!()

    {body, conn, state}
  end
end
