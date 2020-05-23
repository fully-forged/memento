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

    {:ok, assign(socket, params: params, entries: entries)}
  end

  @impl true
  def handle_params(qs_params, _url, socket) do
    {:ok, url_params} = QsParamsValidator.validate(qs_params)
    params = Map.merge(socket.assigns.params, url_params)

    if url_params !== socket.assigns.params do
      entries = Entry.search(params)

      {:noreply, assign(socket, params: params, entries: entries)}
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

  def handle_event("load_more", %{}, socket) do
    params = Map.update!(socket.assigns.params, :page, fn current -> current + 1 end)

    new_entries = Entry.search(params)
    {:noreply, assign(socket, params: params, entries: socket.assigns.entries ++ new_entries)}
  end

  @impl true
  def handle_info(%{status: :success, new_count: new_count}, socket)
      when new_count > 0 do
    entries = Entry.search(socket.assigns.params)
    {:noreply, assign(socket, entries: entries)}
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
end
