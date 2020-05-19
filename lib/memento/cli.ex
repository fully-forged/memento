defmodule Memento.CLI do
  @moduledoc """
  This CLI module allows browsing a memento instance from the command line.

  The module gets compiled to a escript executable (via `mix escript.build`)
  which requires a compatible version of Erlang to run. The binary will be available
  at `bin/memento`.

  Details around switches and options are available via the `--help` flag.
  """

  @switches [
    base_url: :string,
    page: :integer,
    per_page: :integer,
    type: :string,
    help: :boolean
  ]

  @default_opts [
    per_page: 10,
    type: "all",
    page: 1
  ]

  @help_text """
  Use the memento CLI utility to fetch entries from a Memento instance.

  Available switches (defaults can be ommitted):

  - #{IO.ANSI.blue()}--help#{IO.ANSI.default_color()} - Display this help text

  - #{IO.ANSI.blue()}--base-url#{IO.ANSI.default_color()} - Usually mandatory, but can be replaced
    by the #{IO.ANSI.blue()}MEMENTO_BASE_URL#{IO.ANSI.default_color()} environment variable.

    Example: https://memento.my-site.com

  - #{IO.ANSI.blue()}--page#{IO.ANSI.default_color()} - Which page to start from (defaults to 1)

    Example: 1

  - #{IO.ANSI.blue()}--per_page#{IO.ANSI.default_color()} - How many items per page (defaults to 10)

    Example: 20

  - #{IO.ANSI.blue()}--type#{IO.ANSI.default_color()} - Which items to display. Can be any of twitter_fav, pinboard_link,
    github_star, instapaper_bookmark, all. Defaults to all.

    Example: pinboard_link
  """

  def main(args) do
    {user_opts, _, _} = OptionParser.parse(args, switches: @switches)
    opts = Keyword.merge(@default_opts, user_opts)

    if Keyword.get(user_opts, :help) do
      IO.puts(@help_text)
      System.halt(0)
    end

    case Keyword.get(opts, :base_url, System.get_env("MEMENTO_BASE_URL")) do
      base_url when is_binary(base_url) ->
        fetch_entries(base_url, opts)

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

  def fetch_entries(base_url, opts) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    initial_qs = Keyword.take(opts, [:page, :per_page])

    qs =
      case Keyword.get(opts, :type) do
        "all" -> initial_qs
        type -> Keyword.put(initial_qs, :type, type)
      end

    entries_url =
      base_url
      |> URI.parse()
      |> Map.put(:path, "/api/entries")
      |> Map.put(:query, URI.encode_query(qs))
      |> URI.to_string()

    with resp = %{status_code: 200} <- Memento.HTTPClient.get(entries_url),
         {:ok, entries} <- Jason.decode(resp.body) do
      Enum.each(entries, fn e ->
        format_entry(e) |> IO.puts()
      end)
    else
      error ->
        IO.puts(:stderr, """
        #{IO.ANSI.red()}
        Memento failed with the following error:

        #{inspect(error)}
        #{IO.ANSI.default_color()}
        """)

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
    #{IO.ANSI.blue() <> screen_name <> IO.ANSI.default_color()} - #{HtmlEntities.decode(text)}
    #{
      unless Enum.empty?(links) do
        IO.ANSI.green()
        Enum.join(links, "\n")
      end

      IO.ANSI.default_color()
    }
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
