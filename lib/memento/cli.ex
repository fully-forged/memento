defmodule Memento.CLI do
  @switches [
    base_url: :string
  ]

  def main(args) do
    {opts, _, _} = OptionParser.parse(args, switches: @switches)

    case Keyword.get(opts, :base_url, System.get_env("MEMENTO_BASE_URL")) do
      base_url when is_binary(base_url) ->
        fetch_entries(base_url)

      _otherwise ->
        IO.puts(:stderr, """
        #{IO.ANSI.red()}
        The Memento CLI needs a base url to work properly.

        The base url can be either passed as an option with --base-url or
        setup as an environment variable with MEMENTO_BASE_URL.

        For example:

          $ ./memento --base-url https://memento.my-site.com

          $ MEMENTO_BASE_URL=https://memento.my-site.com ./memento
        #{IO.ANSI.default_color()}
        """)

        System.halt(1)
    end
  end

  def fetch_entries(base_url) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    entries_url = base_url <> "/entries"

    with resp <- Memento.HTTPClient.get(entries_url),
         200 <- resp.status_code,
         {:ok, entries} <- Poison.decode(resp.body) do
      Enum.each(entries, fn e ->
        format_entry(e) |> IO.puts()
      end)
    else
      error ->
        IO.puts(:stderr, inspect(error))
        System.halt(1)
    end
  end

  defp format_entry(entry = %{"type" => "twitter_fav"}) do
    screen_name = get_in(entry, ["content", "screen_name"])
    text = get_in(entry, ["content", "text"])
    links = get_in(entry, ["content", "urls"])
    saved_at = entry |> Map.get("saved_at") |> format_date

    """
    (TW) #{saved_at}
    #{IO.ANSI.blue() <> screen_name <> IO.ANSI.default_color()} - #{text}
    #{IO.ANSI.green()}
    #{Enum.map(links, fn l -> l <> "\n" end)} #{IO.ANSI.default_color()}
    """
  end

  defp format_entry(entry = %{"type" => "instapaper_bookmark"}) do
    title = get_in(entry, ["content", "title"])
    url = get_in(entry, ["content", "url"])
    saved_at = entry |> Map.get("saved_at") |> format_date

    """
    (I) #{saved_at}
    #{IO.ANSI.blue() <> title <> IO.ANSI.default_color()}
    #{IO.ANSI.green() <> url <> IO.ANSI.default_color()}
    """
  end

  defp format_entry(entry = %{"type" => "github_star"}) do
    owner = get_in(entry, ["content", "owner"])
    name = get_in(entry, ["content", "name"])
    description = get_in(entry, ["content", "description"])
    url = get_in(entry, ["content", "url"])
    saved_at = entry |> Map.get("saved_at") |> format_date

    """
    (GH) #{saved_at}
    #{IO.ANSI.blue() <> owner <> IO.ANSI.default_color()} - #{name}
    #{description}
    #{IO.ANSI.green() <> url <> IO.ANSI.default_color()}
    """
  end

  defp format_entry(entry = %{"type" => "pinboard_link"}) do
    description = get_in(entry, ["content", "description"])
    url = get_in(entry, ["content", "href"])
    saved_at = entry |> Map.get("saved_at") |> format_date

    """
    (P) #{saved_at}
    #{IO.ANSI.blue() <> description <> IO.ANSI.default_color()}
    #{IO.ANSI.green() <> url <> IO.ANSI.default_color()}
    """
  end

  def format_date(datetime_string) do
    format = 'd-m-Y, H:i'
    {:ok, datetime} = NaiveDateTime.from_iso8601(datetime_string)
    erlang_datetime = NaiveDateTime.to_erl(datetime)
    :ec_date.format(format, erlang_datetime)
  end
end
