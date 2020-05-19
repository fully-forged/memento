defmodule MementoWeb.EntriesLive do
  use MementoWeb, :live_view

  alias Memento.{Entry, RateLimiter, Schema}
  alias MementoWeb.{EntryView, QsParamsValidator}

  @impl true
  def mount(qs_params, _session, socket) do
    {:ok, params} = QsParamsValidator.validate(qs_params)

    entries = Entry.search(params)
    {:ok, assign(socket, params: params, entries: entries)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    params =
      socket.assigns.params
      |> Map.put(:type, :all)
      |> Map.put(:q, query)

    entries = Entry.search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("filter_by_type", %{"type" => type_string}, socket) do
    {:ok, type} = Schema.Entry.Type.load(type_string)

    params =
      socket.assigns.params
      |> Map.put(:type, type)
      |> Map.put(:q, "")

    entries = Entry.search(params)
    {:noreply, assign(socket, params: params, entries: entries)}
  end

  def handle_event("load_more", %{}, socket) do
    params = Map.update!(socket.assigns.params, :page, fn current -> current + 1 end)

    new_entries = Entry.search(params)
    {:noreply, assign(socket, params: params, entries: socket.assigns.entries ++ new_entries)}
  end

  def handle_event("refresh", %{}, socket) do
    if RateLimiter.can_access?(:capture_refresh) do
      RateLimiter.inc(:capture_refresh)

      Memento.Capture.refresh_feeds()
      params = %{socket.assigns.params | type: :all, q: "", page: 1}

      entries = Entry.search(socket.assigns.params)
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
end
