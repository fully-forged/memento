defmodule Memento.Capture.Instapaper.Handler do
  @behaviour Memento.Capture.Handler

  alias Memento.Capture.Instapaper.{Bookmark, Client}

  def entry_type, do: :instapaper_bookmark

  def get_saved_at(content), do: content.time

  def initial_data do
    %{
      consumer_key: System.get_env("INSTAPAPER_OAUTH_CONSUMER_KEY"),
      consumer_secret: System.get_env("INSTAPAPER_OAUTH_CONSUMER_SECRET"),
      username: System.get_env("INSTAPAPER_USERNAME"),
      password: System.get_env("INSTAPAPER_PASSWORD")
    }
  end

  def authorize(data) do
    case Client.get_access_token(
           data.consumer_key,
           data.consumer_secret,
           data.username,
           data.password
         ) do
      {:ok, %{"oauth_token" => token, "oauth_token_secret" => token_secret}} ->
        new_data =
          data
          |> Map.put(:token, token)
          |> Map.put(:token_secret, token_secret)

        {:ok, new_data}

      error ->
        error
    end
  end

  def refresh(data) do
    case Client.get_bookmarks(
           data.consumer_key,
           data.consumer_secret,
           data.token,
           data.token_secret
         ) do
      {:ok, resp} ->
        bookmark_contents =
          resp
          |> Enum.filter(fn element ->
               Map.get(element, "type") == "bookmark"
             end)
          |> Enum.map(&Bookmark.content_from_api_result/1)

        {:ok, bookmark_contents, data}

      error ->
        error
    end
  end
end
