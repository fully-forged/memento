defmodule Memento.Capture.Twitter.Fav do
  @moduledoc false

  def content_from_api_result(result) do
    %{"id_str" => id_str, "text" => text, "created_at" => created_at_str} = result

    screen_name = get_in(result, ["user", "screen_name"])

    urls = get_in(result, ["entities", "urls", Access.all(), "expanded_url"])

    media_urls =
      case get_in(result, ["entities", "media"]) do
        nil -> []
        media -> get_in(media, [Access.all(), "expanded_url"])
      end

    {:ok, created_at} = parse_created_at(created_at_str)

    %{
      id: id_str,
      text: text,
      screen_name: screen_name,
      urls: urls ++ media_urls,
      created_at: created_at
    }
  end

  defp parse_created_at(created_at) do
    created_at
    |> String.to_charlist()
    |> :ec_date.parse()
    |> NaiveDateTime.from_erl()
  end
end
