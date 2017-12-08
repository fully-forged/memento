defmodule Memento.Capture.Pinboard.Feed do
  use GenServer

  require Logger

  alias Memento.{Entry.Query, Repo, Schema.Entry}
  alias Memento.Capture.Pinboard.{Client, Link}

  @retry_interval 5000
  @refresh_interval 1000 * 60 * 5

  def start_link({token, name}) do
    GenServer.start_link(__MODULE__, token, name: name)
  end

  def start_link(token) do
    GenServer.start_link(__MODULE__, token)
  end

  def init(token) do
    send(self(), :get_links)
    {:ok, token}
  end

  def handle_info(:get_links, token) do
    max_saved_at = get_max_saved_at()

    case Client.get_links(token, max_saved_at) do
      {:ok, resp} ->
        resp
        |> Enum.map(&Link.content_from_api_result/1)
        |> insert_all()

        Process.send_after(self(), :get_links, @refresh_interval)

      error ->
        Logger.error(fn ->
          """
          Cannot fetch Pinboard links. Reason:

          #{inspect(error)}

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(self(), :get_links, @retry_interval)
    end

    {:noreply, token}
  end

  defp get_max_saved_at do
    Query.max_pinboard_saved_at()
    |> Repo.one()
  end

  defp insert_all(links) do
    now = DateTime.utc_now()

    inserts =
      Enum.map(links, fn link ->
        [
          type: :pinboard_link,
          content: link,
          saved_at: link.time,
          inserted_at: now,
          updated_at: now
        ]
      end)

    Repo.insert_all(Entry, inserts, on_conflict: :nothing)
  end
end
