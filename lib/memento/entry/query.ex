defmodule Memento.Entry.Query do
  import Ecto.Query

  alias Memento.Schema.Entry

  def max_tweet_id do
    from e in Entry,
      where: e.type == ^:twitter_fav,
      select: fragment("MAX(content ->> 'id')")
  end
end
