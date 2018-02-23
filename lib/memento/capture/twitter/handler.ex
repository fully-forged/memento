defmodule Memento.Capture.Twitter.Handler do
  @moduledoc false
  @behaviour Memento.Capture.Handler

  alias Memento.Capture.Twitter.{Client, Fav}
  alias Memento.{Entry.Query, Repo}

  def entry_type, do: :twitter_fav

  def get_saved_at(content), do: content.created_at

  def initial_data do
    %{
      username: Application.get_env(:memento, :twitter_username),
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    }
  end

  def authorize(data) do
    case Client.get_token(data.consumer_key, data.consumer_secret) do
      {:ok, %{"access_token" => access_token}} ->
        {:ok, Map.put(data, :access_token, access_token)}

      error ->
        error
    end
  end

  def refresh(data) do
    max_tweet_id = get_max_tweet_id()

    case Client.get_favs(data.access_token, data.username, max_tweet_id) do
      {:ok, resp} ->
        {:ok, Enum.map(resp, &Fav.content_from_api_result/1), data}

      error ->
        error
    end
  end

  defp get_max_tweet_id do
    Query.max_tweet_id()
    |> Repo.one()
  end
end
