defmodule MementoWeb.EntriesLiveTest do
  use MementoWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Memento.{Generators, Repo, Schema.Entry}
  alias MementoWeb.EntryView

  setup :generate_entries

  describe "the entries list" do
    test "shows the entry data", %{conn: conn, entries: entries, entries_count: entries_count} do
      {:ok, entry_live, html} = live(conn, "/?per_page=#{entries_count}")

      for entry <- entries, do: assert_rendered_entry(entry, entry_live, html)
    end

    test "can be filtered by type", %{conn: conn, entries: entries} do
      grouped_entries = Enum.group_by(entries, fn e -> e.type end)
      available_types = Map.keys(grouped_entries)

      {:ok, entry_live, _html} = live(conn, "/")

      Enum.each(available_types, fn type ->
        {entries_for_type, other_types} = Map.pop(grouped_entries, type)

        entries_for_other_types =
          other_types
          |> Map.values()
          |> List.flatten()

        html =
          entry_live
          |> render_patch("?type=#{type}")

        for entry <- entries_for_type, do: assert_rendered_entry(entry, entry_live, html)
        for entry <- entries_for_other_types, do: refute_rendered_entry(entry, entry_live, html)
      end)
    end

    test "can be searched", %{conn: conn, entries: entries} do
      {:ok, entry_live, html} = live(conn, "/")

      for entry <- entries do
        description = EntryView.description(entry)

        q =
          description
          |> String.split(" ")
          |> Enum.take_random(2)
          |> Enum.join(" ")

        results_html =
          entry_live
          |> element(".filters")
          |> render_change(%{q: q})

        assert results_html !== html
        assert_rendered_entry(entry, entry_live, results_html)
      end
    end

    test "is paginated", %{conn: conn, entries: entries, entries_count: entries_count} do
      per_page = div(entries_count, 2)

      {page_one_entries, page_two_entries} =
        entries
        |> Enum.sort_by(fn e -> e.saved_at end, {:desc, DateTime})
        |> Enum.split(per_page)

      {:ok, entry_live, page_one_html} = live(conn, "/?per_page=#{per_page}")

      for entry <- page_one_entries, do: assert_rendered_entry(entry, entry_live, page_one_html)
      for entry <- page_two_entries, do: refute_rendered_entry(entry, entry_live, page_one_html)

      {:ok, entry_live, page_two_html} =
        live(conn, "/?page=2&per_page=#{per_page + rem(entries_count, 2)}")

      for entry <- page_one_entries,
          do: refute_rendered_entry(entry, entry_live, page_two_html)

      for entry <- page_two_entries,
          do: assert_rendered_entry(entry, entry_live, page_two_html)
    end

    test "receives automatic updates", %{conn: conn} do
      {:ok, entry_live, html} = live(conn, "/")

      [entry] = Enum.take(Generators.entry(), 1)

      {:ok, entry} = Repo.insert(entry)

      send(entry_live.pid, %{status: :success, new_count: 1})

      new_html = render(entry_live)

      assert new_html !== html
      assert_rendered_entry(entry, entry_live, new_html)
    end
  end

  defp generate_entries(_context) do
    entries_count = :rand.uniform(20)
    attributes = Enum.take(Generators.entry_attributes(), entries_count)

    {^entries_count, entries} = Repo.insert_all(Entry, attributes, returning: true)

    [entries: entries, entries_count: entries_count]
  end

  defp assert_rendered_entry(entry, entry_live, html) do
    case entry.type do
      :github_star ->
        assert html =~ Map.get(entry.content, "name")
        assert html =~ Map.get(entry.content, "description")

        assert has_element?(entry_live, ".entry .content h1", Map.get(entry.content, "name"))

        assert has_element?(
                 entry_live,
                 ".entry .content h2",
                 Map.get(entry.content, "description")
               )

      :twitter_fav ->
        assert html =~ Map.get(entry.content, "screen_name")
        assert html =~ Map.get(entry.content, "text")

        assert has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "screen_name")
               )

        assert has_element?(entry_live, ".entry .content h2", Map.get(entry.content, "text"))

      :pinboard_link ->
        assert html =~ Map.get(entry.content, "description")

        assert has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "description")
               )

      :instapaper_bookmark ->
        assert html =~ Map.get(entry.content, "title")

        assert has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "title")
               )
    end
  end

  defp refute_rendered_entry(entry, entry_live, html) do
    case entry.type do
      :github_star ->
        refute html =~ Map.get(entry.content, "name")
        refute html =~ Map.get(entry.content, "description")

        refute has_element?(entry_live, ".entry .content h1", Map.get(entry.content, "name"))

        refute has_element?(
                 entry_live,
                 ".entry .content h2",
                 Map.get(entry.content, "description")
               )

      :twitter_fav ->
        refute html =~ Map.get(entry.content, "screen_name")
        refute html =~ Map.get(entry.content, "text")

        refute has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "screen_name")
               )

        refute has_element?(entry_live, ".entry .content h2", Map.get(entry.content, "text"))

      :pinboard_link ->
        refute html =~ Map.get(entry.content, "description")

        refute has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "description")
               )

      :instapaper_bookmark ->
        refute html =~ Map.get(entry.content, "title")

        refute has_element?(
                 entry_live,
                 ".entry .content h1",
                 Map.get(entry.content, "title")
               )
    end
  end
end
