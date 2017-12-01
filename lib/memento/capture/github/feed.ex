defmodule Memento.Capture.Github.Feed do
  use GenServer

  require Logger

  alias Memento.{Repo, Schema.Entry}
  alias Memento.Capture.Github.{Client, StarredRepo}

  @retry_interval 5000
  @refresh_interval 1000 * 60 * 5

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ignored, name: name)
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ignored)
  end

  def init(:ignored) do
    send(self(), :get_starred_repos)
    {:ok, :ignored}
  end

  def handle_info(:get_starred_repos, token) do
    case Client.get_stars_by_username("cloud8421") do
      {:ok, resp, _} ->
        resp
        |> Enum.map(&StarredRepo.content_from_api_result/1)
        |> insert_all()

        Process.send_after(self(), :get_starred_repos, @refresh_interval)

      error ->
        Logger.error(fn ->
          """
          Cannot fetch starred repos. Reason:

          #{inspect(error)}

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(self(), :get_starred_repos, @retry_interval)
    end

    {:noreply, token}
  end

  defp insert_all(starred_repos) do
    now = DateTime.utc_now()

    inserts =
      Enum.map(starred_repos, fn sr ->
        [
          type: :github_star,
          content: sr,
          saved_at: sr.starred_at,
          inserted_at: now,
          updated_at: now
        ]
      end)

    Repo.insert_all(Entry, inserts, on_conflict: :nothing)
  end
end
