defmodule MementoWeb.EntriesLive do
  use MementoWeb, :live_view

  alias Memento.{Capture, Entry}
  alias MementoWeb.{EntriesLive, EntryView, QsParamsValidator}

  @impl true
  def mount(qs_params, _session, socket) do
    if connected?(socket) do
      Capture.subscribe()
    end

    {:ok, params} = QsParamsValidator.validate(qs_params)

    entries = Entry.search(params)
    entries_count = Entry.count(params)

    {:ok, assign(socket, params: params, entries: entries, entries_count: entries_count)}
  end

  @impl true
  def handle_params(qs_params, _url, socket) do
    {:ok, url_params} = QsParamsValidator.validate(qs_params)
    params = Map.merge(socket.assigns.params, url_params)

    if url_params !== socket.assigns.params do
      entries = Entry.search(params)
      entries_count = Entry.count(params)

      {:noreply, assign(socket, params: params, entries: entries, entries_count: entries_count)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    params =
      socket.assigns.params
      |> Map.drop([:page, :per_page, :type])
      |> Map.put(:q, query)

    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  @impl true
  def handle_info(%{status: :success, new_count: new_count}, socket)
      when new_count > 0 do
    entries = Entry.search(socket.assigns.params)
    entries_count = Entry.count(socket.assigns.params)
    {:noreply, assign(socket, entries: entries, entries_count: entries_count)}
  end

  def handle_info(_capture_event, socket) do
    {:noreply, socket}
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

  def pagination(%{page: page, per_page: per_page} = params, entries_count, socket) do
    total_pages = div(entries_count, per_page)
    next_page = page + 1
    previous_page = page - 1

    case {previous_page, next_page} do
      {0, next_page} ->
        [
          content_tag(:a, "<", class: "disabled"),
          live_patch(">",
            to: Routes.live_path(socket, __MODULE__, Map.put(params, :page, next_page))
          )
        ]

      {previous_page, next_page} when next_page == total_pages + 1 ->
        [
          live_patch("<",
            to: Routes.live_path(socket, __MODULE__, Map.put(params, :page, previous_page))
          ),
          content_tag(:a, ">", class: "disabled")
        ]

      {previous_page, next_page} ->
        [
          live_patch("<",
            to: Routes.live_path(socket, __MODULE__, Map.put(params, :page, previous_page))
          ),
          live_patch(">",
            to: Routes.live_path(socket, __MODULE__, Map.put(params, :page, next_page))
          )
        ]
    end
  end
end
