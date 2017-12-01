defmodule Memento.Capture.Github.Link do
  @link_matcher ~r/^<(?<url>.*)>; rel="(?<rel>.*)"$/

  def parse_headers(headers) do
    :proplists.get_value("link", headers)
    |> String.split(", ", trim: true)
    |> Enum.map(&parse_link/1)
    |> Enum.into(%{})
  end

  defp parse_link(link) do
    %{"rel" => rel, "url" => url} = Regex.named_captures(@link_matcher, link)
    {parse_rel(rel), url}
  end

  defp parse_rel("next"), do: :next
  defp parse_rel("first"), do: :first
  defp parse_rel("last"), do: :last
  defp parse_rel("prev"), do: :prev
end
