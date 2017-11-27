defmodule Memento.Capture.Twitter.Client do
  alias Memento.HTTPClient

  def get_token(consumer_key, consumer_secret) do
    content_type = "application/x-www-form-urlencoded;charset=UTF-8"
    headers = [basic_auth(consumer_key, consumer_secret)]
    url = "https://api.twitter.com/oauth2/token"
    body = "grant_type=client_credentials"

    case HTTPClient.post(url, headers, body, content_type) do
      %{status_code: 200, body: resp_body} ->
        Poison.decode(resp_body)

      error_response = %HTTPClient.ErrorResponse{} ->
        {:error, error_response}

      other_error ->
        other_error
    end
  end

  def get_favs(token, screen_name, since) do
    headers = [{"Authorization", "Bearer #{token}"}]
    url = "https://api.twitter.com/1.1/favorites/list.json"
    params = qs_params(screen_name, since)

    case HTTPClient.get(url, headers, params) do
      %{status_code: 200, body: resp_body} ->
        Poison.decode(resp_body)

      error_response = %HTTPClient.ErrorResponse{} ->
        {:error, error_response}

      other_error ->
        other_error
    end
  end

  defp qs_params(screen_name, nil) do
    %{"screen_name" => screen_name}
  end

  defp qs_params(screen_name, since) do
    %{"screen_name" => screen_name, "since" => since}
  end

  defp basic_auth(consumer_key, consumer_secret) do
    encoded = Base.encode64(consumer_key <> ":" <> consumer_secret)
    {"Authorization", "Basic " <> encoded}
  end
end
