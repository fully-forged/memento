defmodule Memento.Entry.Query do
  import Ecto.Query

  alias Memento.Schema.Entry

  def max_tweet_id do
    from e in Entry,
      where: e.type == ^:twitter_fav,
      select: fragment("MAX(content ->> 'id')")
  end

  def search(search_query) do
    from e in Entry,
      join: si in Entry.SearchIndex,
      on: [id: e.id],
      where: fragment(
        "to_tsvector('english', text) @@ to_tsquery(?)",
        ^search_query
      ),
      order_by: [desc: :saved_at]
  end
end
