defmodule MementoWeb.EntriesLive do
  use MementoWeb, :live_view

  alias Memento.{API.QsParamsValidator, Entry.Query, RateLimiter, Repo, Schema.Entry}
  alias MementoWeb.EntryView

  # Should expose functions to:
  #
  # - [x] Filter by entry type
  # - [x] Full text search
  # - [x] Load an additional page of content (respecting current filtering)
  #
  # Should be auto-updated when any new entry matching current filters
  # is created.

  @impl true
  def mount(qs_params, _session, socket) do
    {:ok, params} = QsParamsValidator.validate(qs_params)

    entries = search(params)
    {:ok, assign(socket, params: params, entries: entries)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    params =
      socket.assigns.params
      |> Map.put(:type, :all)
      |> Map.put(:q, query)

    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("filter_by_type", %{"type" => type_string}, socket) do
    {:ok, type} = Entry.Type.load(type_string)

    params =
      socket.assigns.params
      |> Map.put(:type, type)
      |> Map.put(:q, "")

    entries = search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("load_more", %{}, socket) do
    params = Map.update!(socket.assigns.params, :page, fn current -> current + 1 end)

    new_entries = search(params)
    {:noreply, assign(socket, params: params, entries: socket.assigns.entries ++ new_entries)}
  end

  def handle_event("refresh", %{}, socket) do
    if RateLimiter.can_access?(:capture_refresh) do
      RateLimiter.inc(:capture_refresh)

      Memento.Capture.refresh_feeds()
      params = %{socket.assigns.params | type: :all, q: "", page: 1}

      entries = search(socket.assigns.params)
      {:noreply, assign(socket, params: params, entries: entries)}
    else
      {:noreply, socket}
    end
  end

  def type_filter_class(type, params) do
    icon_class =
      case type do
        :github_star -> "icon-github"
        :twitter_fav -> "icon-twitter"
        :pinboard_link -> "icon-pushpin"
        :instapaper_bookmark -> "icon-instapaper"
        :all -> ""
      end

    if type == params.type do
      icon_class <> " " <> "active"
    else
      icon_class
    end
  end

  defp search(%{q: q, type: type, page: page, per_page: per_page}) do
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
