defmodule Memento.Capture.Github.Client do
  alias Memento.{HTTPClient, Capture.Github}

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

  @spec get_stars_by_url(url) :: {:ok, [map]} | {:error, term}
  def get_stars_by_url(url) do
    headers = %{
      "Accept" => "application/vnd.github.v3.star+json",
      "User-Agent" => "Username: fullyforged"
    }

    with %HTTPClient.Response{
           status_code: 200,
           headers: resp_headers,
           body: body
         } <- HTTPClient.get(url, headers),
         {:ok, data} <- Poison.decode(body),
         links <- Github.Link.parse_headers(resp_headers) do
      {:ok, parse_starred_repos(data), links}
    else
      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  def parse_starred_repos(data) do
    Enum.map(data, &Github.StarredRepo.content_from_api_result/1)
  end
end
