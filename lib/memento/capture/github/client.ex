defmodule Memento.Capture.Github.Client do
  alias Memento.HTTPClient

  @link_matcher ~r/^<(?<url>.*)>; rel="(?<rel>.*)"$/

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
         links <- parse_links(resp_headers) do
      {:ok, parse_starred_repos(data), links}
    else
      %HTTPClient.Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}

      %HTTPClient.ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  def parse_starred_repos(data) do
    Enum.map(data, &parse_starred_repo/1)
  end

  def parse_links(headers) do
    :proplists.get_value("link", headers)
    |> String.split(", ", trim: true)
    |> Enum.map(&parse_link/1)
    |> Enum.into(%{})
  end

  defp parse_starred_repo(starred_repo) do
    starred_at =
      starred_repo
      |> Map.get("starred_at")
      |> parse_datetime

    created_at =
      starred_repo
      |> get_in(["repo", "created_at"])
      |> parse_datetime

    pushed_at =
      starred_repo
      |> get_in(["repo", "pushed_at"])
      |> parse_datetime

    %{
      id: get_in(starred_repo, ["repo", "id"]),
      owner: get_in(starred_repo, ["repo", "owner", "login"]),
      name: get_in(starred_repo, ["repo", "name"]),
      description: get_in(starred_repo, ["repo", "description"]),
      created_at: created_at,
      pushed_at: pushed_at,
      starred_at: starred_at
    }
  end

  defp parse_link(link) do
    %{"rel" => rel, "url" => url} = Regex.named_captures(@link_matcher, link)
    {parse_rel(rel), url}
  end

  defp parse_rel("next"), do: :next
  defp parse_rel("first"), do: :first
  defp parse_rel("last"), do: :last
  defp parse_rel("prev"), do: :prev

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> datetime
      _error -> nil
    end
  end
end
