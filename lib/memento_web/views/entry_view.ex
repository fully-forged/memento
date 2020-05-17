defmodule MementoWeb.EntryView do
  use MementoWeb, :view

  def title(entry) do
    case entry.type do
      :github_star -> Map.get(entry.content, "name")
      :twitter_fav -> Map.get(entry.content, "screen_name")
      :pinboard_link -> Map.get(entry.content, "description")
      :instapaper_bookmark -> Map.get(entry.content, "title")
    end
  end

  def description(entry) do
    case entry.type do
      :github_star -> Map.get(entry.content, "description")
      :twitter_fav -> Map.get(entry.content, "text")
      :pinboard_link -> Map.get(entry.content, "description")
      :instapaper_bookmark -> Map.get(entry.content, "title")
    end
  end

  def urls(entry) do
    case entry.type do
      :github_star -> [Map.get(entry.content, "url")]
      :twitter_fav -> Map.get(entry.content, "urls")
      :pinboard_link -> [Map.get(entry.content, "href")]
      :instapaper_bookmark -> [Map.get(entry.content, "url")]
    end
  end

  def icon(entry) do
    case entry.type do
      :github_star -> "icon-github"
      :twitter_fav -> "icon-twitter"
      :pinboard_link -> "icon-pushpin"
      :instapaper_bookmark -> "icon-instapaper"
    end
  end

  def saved_at(entry) do
    DateTime.to_string(entry.saved_at)
  end
end
