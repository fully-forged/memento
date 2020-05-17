defmodule MementoWeb.EntriesLive do
  use MementoWeb, :live_view

  alias Memento.{API.QsParamsValidator, Entry.Query, Repo, Schema.Entry}
  alias MementoWeb.EntryView

  @impl true
  def mount(params, _session, socket) do
    entries = search(params)
    {:ok, assign(socket, params: params, entries: entries)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    params = Map.put(socket.assigns.params, "q", query)
    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  defp search(params) do
    {:ok, %{page: page, per_page: per_page, type: type, q: q}} =
      QsParamsValidator.validate(params)

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

    Repo.all(with_filters_query)
  end
end
