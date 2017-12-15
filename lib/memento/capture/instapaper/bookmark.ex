defmodule Memento.Capture.Instapaper.Bookmark do
  def content_from_api_result(result) do
    %{"bookmark_id" => id, "title" => title, "url" => url, "time" => unix_time} =
      result

    {:ok, time} = DateTime.from_unix(unix_time)

    %{id: to_string(id), title: title, url: url, time: time}
  end
end
