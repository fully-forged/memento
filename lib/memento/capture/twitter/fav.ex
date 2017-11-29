defmodule Memento.Capture.Twitter.Fav do
  def content_from_api_result(result) do
    %{"id_str" => id_str, "text" => text, "created_at" => created_at} = result

    screen_name = get_in(result, ["user", "screen_name"])

    urls = get_in(result, ["entities", "urls", Access.all(), "url"])

    %{id: id_str, text: text, screen_name: screen_name, urls: urls, created_at: created_at}
  end
end
