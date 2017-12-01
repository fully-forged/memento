defmodule Memento.Capture.Twitter.Feed do
  use GenServer

  require Logger

  alias Memento.{Entry.Query, Repo, Schema.Entry}
  alias Memento.Capture.Twitter.{Client, Fav}

  @retry_interval 5000
  @refresh_interval 1000 * 60 * 5

  def start_link({consumer_key, consumer_secret, name}) do
    GenServer.start_link(
      __MODULE__,
      {consumer_key, consumer_secret},
      name: name
    )
  end

  def start_link(consumer_key, consumer_secret) do
    GenServer.start_link(__MODULE__, {consumer_key, consumer_secret})
  end

  def init({consumer_key, consumer_secret}) do
    send(self(), {:get_token, consumer_key, consumer_secret})
    {:ok, :no_token}
  end

  def handle_info({:get_token, consumer_key, consumer_secret}, _maybe_token) do
    case Client.get_token(consumer_key, consumer_secret) do
      {:ok, resp} ->
        max_tweet_id = get_max_tweet_id()
        send(self(), {:get_favs, max_tweet_id})
        {:noreply, Map.get(resp, "access_token")}

      _error ->
        Logger.error(fn ->
          """
          Cannot fetch valid token with supplied Twitter credentials.

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(
          self(),
          {:get_token, consumer_key, consumer_secret},
          @retry_interval
        )

        {:noreply, :no_token}
    end
  end

  def handle_info({:get_favs, max_tweet_id}, token) do
    case Client.get_favs(token, "cloud8421", max_tweet_id) do
      {:ok, resp} ->
        resp
        |> Enum.map(&Fav.content_from_api_result/1)
        |> insert_all()

        max_tweet_id = get_max_tweet_id()

        Process.send_after(self(), {:get_favs, max_tweet_id}, @refresh_interval)

      error ->
        Logger.error(fn ->
          """
          Cannot fetch favs. Reason:

          #{inspect(error)}

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(self(), {:get_favs, max_tweet_id}, @retry_interval)
    end

    {:noreply, token}
  end

  defp get_max_tweet_id do
    Query.max_tweet_id()
    |> Repo.one()
  end

  defp insert_all(favs) do
    now = DateTime.utc_now()

    inserts =
      Enum.map(favs, fn fav ->
        [
          type: :twitter_fav,
          content: fav,
          saved_at: fav.created_at,
          inserted_at: now,
          updated_at: now
        ]
      end)

    Repo.insert_all(Entry, inserts, on_conflict: :nothing)
  end
end
