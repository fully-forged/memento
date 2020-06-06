defmodule Memento.Entry.Query do
  @moduledoc false
  import Ecto.Query

  alias Memento.Schema.Entry

  def ordered_by_saved_at_desc(initial, limit, offset) do
    from e in initial,
      order_by: [desc: :saved_at],
      limit: ^limit,
      offset: ^offset
  end

  def by_type(initial, type) do
    from e in initial, where: e.type == ^type
  end

  def max_tweet_id do
    from e in Entry,
      where: e.type == ^:twitter_fav,
      select: fragment("MAX(content ->> 'id')")
  end

  def max_pinboard_saved_at do
    from e in Entry,
      where: e.type == ^:pinboard_link,
      select: max(e.saved_at)
  end

  def search(initial, search_query) do
    from e in initial,
      where:
        fragment(
          "to_tsvector('english', content) @@ plainto_tsquery(?)",
          ^search_query
        )
  end
end
