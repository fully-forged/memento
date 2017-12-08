defmodule Memento.Capture.Pinboard.Link do
  def content_from_api_result(result) do
    %{
      "hash" => id,
      "description" => description,
      "href" => href,
      "tags" => tags_string,
      "time" => time_string
    } = result

    {:ok, time, _} = DateTime.from_iso8601(time_string)
    tags = String.split(tags_string, " ")

    %{id: id, description: description, href: href, tags: tags, time: time}
  end
end
