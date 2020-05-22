defmodule Memento.Capture.Github.Client do
  @moduledoc false
  alias Memento.HTTPClient

  @type username :: String.t()
  @type url :: String.t()

  @spec url_for(username) :: url
  def url_for(username) do
    "https://api.github.com/users/" <> username <> "/starred"
  end

  @spec get_stars_by_username(username) :: {:ok, [map]} | {:error, term}
  def get_stars_by_username(username) do
    username
    |> url_for
    |> get_stars_by_url
  end

  @spec get_stars_by_url(url) :: {:ok, [map()]} | {:error, term}
  def get_stars_by_url(url) do
    headers = [
      {"Accept", "application/vnd.github.v3.star+json"},
      {"User-Agent", "Username: fullyforged"}
    ]

    case HTTPClient.get(url, headers) do
      %HTTPClient.Response{status_code: 200, body: body} ->
        Jason.decode(body)

      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end
end
