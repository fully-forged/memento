defmodule MementoWeb.EntriesLive do
  use MementoWeb, :live_view

  alias Memento.{API.QsParamsValidator, Entry.Query, Repo, Schema.Entry}
  alias MementoWeb.EntryView

  # Should expose functions to:
  #
  # - [x] Filter by entry type
  # - [x] Full text search
  # - [ ] Load an additional page of content (respecting current filtering)
  #
  # Should be auto-updated when any new entry matching current filters
  # is created.

  @impl true
  def mount(params, _session, socket) do
    entries = search(params)
    {:ok, assign(socket, params: params, entries: entries)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    params =
      socket.assigns.params
      |> Map.delete("type")
      |> Map.put("q", query)

    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("filter_by_type", %{"type" => "all"}, socket) do
    params =
      socket.assigns.params
      |> Map.delete("type")
      |> Map.delete("q")

    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("filter_by_type", %{"type" => type}, socket) do
    params =
      socket.assigns.params
      |> Map.put("type", type)
      |> Map.delete("q")

    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def type_filter_class(type, params) do
    icon_class =
      case type do
        "github_star" -> "icon-github"
        "twitter_fav" -> "icon-twitter"
        "pinboard_link" -> "icon-pushpin"
        "instapaper_bookmark" -> "icon-instapaper"
        "all" -> ""
      end

    selected_type = Map.get(params, "type", "all")

    if type == selected_type do
      icon_class <> " " <> "active"
    else
      icon_class
    end
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
