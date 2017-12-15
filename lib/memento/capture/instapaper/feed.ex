defmodule Memento.Capture.Instapaper.Feed do
  use GenServer

  require Logger

  alias Memento.{Repo, Schema.Entry}
  alias Memento.Capture.Instapaper.{Client, Bookmark}

  @retry_interval 5000
  @refresh_interval 1000 * 60 * 5

  def start_link({consumer_key, consumer_secret, username, password, name}) do
    GenServer.start_link(
      __MODULE__,
      {consumer_key, consumer_secret, username, password},
      name: name
    )
  end

  def start_link(consumer_key, consumer_secret, username, password) do
    GenServer.start_link(__MODULE__, {
      consumer_key,
      consumer_secret,
      username,
      password
    })
  end

  def init({consumer_key, consumer_secret, username, password}) do
    send(self(), {
      :get_oauth_creds,
      consumer_key,
      consumer_secret,
      username,
      password
    })

    {:ok, :no_oauth_creds}
  end

  def handle_info(
        {:get_oauth_creds, consumer_key, consumer_secret, username, password},
        _maybe_oauth_creds
      ) do
    case Client.get_access_token(
           consumer_key,
           consumer_secret,
           username,
           password
         ) do
      {:ok, resp} ->
        %{"oauth_token" => token, "oauth_token_secret" => token_secret} = resp
        send(self(), {:get_bookmarks, consumer_key, consumer_secret})
        {:noreply, {token, token_secret}}

      _error ->
        Logger.error(fn ->
          """
          Cannot fetch valid oauth params with these credentials

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(
          self(),
          {:get_oauth_creds, consumer_key, consumer_secret, username, password},
          @retry_interval
        )

        {:noreply, :no_oauth_creds}
    end
  end

  def handle_info({:get_bookmarks, consumer_key, consumer_secret}, {
        token,
        token_secret
      }) do
    case Client.get_bookmarks(
           consumer_key,
           consumer_secret,
           token,
           token_secret
         ) do
      {:ok, resp} ->
        resp
        |> Enum.filter(fn element -> Map.get(element, "type") == "bookmark" end)
        |> Enum.map(&Bookmark.content_from_api_result/1)
        |> insert_all()

        Process.send_after(
          self(),
          {:get_bookmarks, consumer_key, consumer_secret},
          @refresh_interval
        )

      error ->
        Logger.error(fn ->
          """
          Cannot fetch bookmarks. Reason:

          #{inspect(error)}

          Retrying in 5 seconds...
          """
        end)

        Process.send_after(
          self(),
          {:get_bookmarks, consumer_key, consumer_secret},
          @retry_interval
        )
    end

    {:noreply, {token, token_secret}}
  end

  defp insert_all(bookmarks) do
    now = DateTime.utc_now()

    inserts =
      Enum.map(bookmarks, fn bookmark ->
        [
          type: :instapaper_bookmark,
          content: bookmark,
          saved_at: bookmark.time,
          inserted_at: now,
          updated_at: now
        ]
      end)

    Repo.insert_all(Entry, inserts, on_conflict: :nothing)
  end
end
