defmodule Memento.Capture.Github.StarredRepo do
  @moduledoc false
  def content_from_api_result(result) do
    starred_at =
      result
      |> Map.get("starred_at")
      |> parse_datetime

    created_at =
      result
      |> get_in(["repo", "created_at"])
      |> parse_datetime

    pushed_at =
      result
      |> get_in(["repo", "pushed_at"])
      |> parse_datetime

    %{
      id: get_in(result, ["repo", "id"]) |> to_string(),
      owner: get_in(result, ["repo", "owner", "login"]),
      name: get_in(result, ["repo", "name"]),
      description: get_in(result, ["repo", "description"]),
      url: get_in(result, ["repo", "html_url"]),
      created_at: created_at,
      pushed_at: pushed_at,
      starred_at: starred_at
    }
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> datetime
      _error -> nil
    end
  end
end
