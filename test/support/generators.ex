defmodule Memento.Generators do
  import StreamData

  alias Memento.Schema.Entry

  def entry, do: bind(entry_type(), &entry_by_type/1)

  def entry_by_type(entry_type) do
    bind(datetime(), fn saved_at ->
      saved_at = DateTime.truncate(saved_at, :second)

      bind(content(entry_type, saved_at), fn content ->
        current_time =
          DateTime.utc_now()
          |> DateTime.truncate(:second)

        entry = %Entry{
          id: Ecto.UUID.generate(),
          type: entry_type,
          content: content,
          saved_at: saved_at,
          inserted_at: current_time,
          updated_at: current_time
        }

        constant(entry)
      end)
    end)
  end

  def entry_attributes do
    map(entry(), fn entry ->
      entry
      |> Map.from_struct()
      |> Map.delete(:__meta__)
    end)
  end

  def entry_type do
    one_of([:twitter_fav, :github_star, :pinboard_link, :instapaper_bookmark])
  end

  def content(:twitter_fav, saved_at) do
    tuple(
      {sentence(), list_of(string(:printable, min_length: 3)), string(:printable, min_length: 3)}
    )
    |> bind(fn {text, urls, screen_name} ->
      constant(%{
        "id" => Ecto.UUID.generate(),
        "text" => text,
        "urls" => urls,
        "screen_name" => screen_name,
        "created_at" => DateTime.to_iso8601(saved_at)
      })
    end)
  end

  def content(:github_star, saved_at) do
    tuple(
      {string(:printable, min_length: 3), string(:printable, min_length: 3),
       string(:printable, min_length: 3), sentence()}
    )
    |> bind(fn {url, name, owner, description} ->
      # repo is created an hour before being saved, with the last push half an
      # hour before being starred
      created_at = DateTime.add(saved_at, -3600, :second)
      pushed_at = DateTime.add(saved_at, -1800, :second)

      constant(%{
        "id" => Ecto.UUID.generate(),
        "url" => url,
        "name" => name,
        "owner" => owner,
        "description" => description,
        "pushed_at" => DateTime.to_iso8601(pushed_at),
        "created_at" => DateTime.to_iso8601(created_at),
        "starred_at" => DateTime.to_iso8601(saved_at)
      })
    end)
  end

  def content(:pinboard_link, saved_at) do
    tuple(
      {string(:printable, min_length: 3), list_of(string(:printable, min_length: 3)), sentence()}
    )
    |> bind(fn {href, tags, description} ->
      constant(%{
        "id" => Ecto.UUID.generate(),
        "href" => href,
        "tags" => tags,
        "description" => description,
        "time" => DateTime.to_iso8601(saved_at)
      })
    end)
  end

  def content(:instapaper_bookmark, saved_at) do
    tuple({string(:printable, min_length: 3), sentence()})
    |> bind(fn {url, title} ->
      constant(%{
        "id" => Ecto.UUID.generate(),
        "url" => url,
        "title" => title,
        "time" => DateTime.to_iso8601(saved_at)
      })
    end)
  end

  def sentence do
    map(list_of(string(:alphanumeric, min_length: 8), min_length: 1), fn words ->
      Enum.join(words, " ")
    end)
  end

  # Lifted from https://gist.github.com/LostKobrakai/7137eb20ed59fc8c6af0e94331cf470c

  @time_zones ["Etc/UTC"]

  def date do
    tuple({integer(2000..2030), integer(1..12), integer(1..31)})
    |> bind_filter(fn tuple ->
      case Date.from_erl(tuple) do
        {:ok, date} -> {:cont, constant(date)}
        _ -> :skip
      end
    end)
  end

  def time do
    tuple({integer(0..23), integer(0..59), integer(0..59)})
    |> map(&Time.from_erl!/1)
  end

  def naive_datetime do
    tuple({date(), time()})
    |> map(fn {date, time} ->
      {:ok, naive_datetime} = NaiveDateTime.new(date, time)
      naive_datetime
    end)
  end

  def datetime do
    tuple({naive_datetime(), member_of(@time_zones)})
    |> map(fn {naive_datetime, time_zone} ->
      DateTime.from_naive!(naive_datetime, time_zone)
    end)
  end
end
