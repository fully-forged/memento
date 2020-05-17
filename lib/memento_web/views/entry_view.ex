defmodule MementoWeb.EntryView do
  use MementoWeb, :view

  def title(entry) do
    case entry.type do
      :github_star -> Map.get(entry.content, "name")
    end
  end

  def description(entry) do
    case entry.type do
      :github_star -> Map.get(entry.content, "description")
    end
  end

  def url(entry) do
    case entry.type do
      :github_star -> Map.get(entry.content, "url")
    end
  end

  def icon(entry) do
    case entry.type do
      :github_star -> "icon-github"
    end
  end

  def saved_at(entry) do
    DateTime.to_string(entry.saved_at)
  end
end
