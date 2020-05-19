defmodule MementoWeb.EntryView do
  use MementoWeb, :view

  def title(entry) do
    case entry.type do
      :github_star ->
        render("two_line_title.html",
          title: entry.content["name"],
          subtitle: entry.content["description"]
        )

      :twitter_fav ->
        render("two_line_title.html",
          title: entry.content["screen_name"],
          subtitle: entry.content["text"]
        )

      :pinboard_link ->
        render("one_line_title.html",
          title: entry.content["description"]
        )

      :instapaper_bookmark ->
        render("one_line_title.html",
          title: entry.content["title"]
        )
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
    Calendar.Strftime.strftime!(entry.saved_at, "%d-%m-%Y, %H:%M")
  end
end
