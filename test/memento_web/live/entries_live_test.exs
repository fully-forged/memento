defmodule MementoWeb.EntriesLiveTest do
  use MementoWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Memento.{Repo, Schema.Entry}

  setup do
    created_at =
      ~N[2017-11-28 15:36:03]
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.truncate(:second)

    content = %{
      id: "935532750223880194",
      text:
        "dialyzex - A Mix task for type-checking your Elixir project with dialyzer https://t.co/CLgZiRapp9",
      screen_name: "oss_elixir",
      urls: ["https://github.com/comcast/dialyzex"],
      created_at: created_at
    }

    now = DateTime.utc_now()

    %Entry{}
    |> Entry.changeset(%{
      type: :twitter_fav,
      content: content,
      saved_at: created_at,
      inserted_at: now,
      updated_at: now
    })
    |> Repo.insert!()

    [content: content]
  end

  describe "disconnected and connected render" do
    test "it shows the entry data", %{conn: conn, content: content} do
      {:ok, page_live, disconnected_html} = live(conn, "/")

      assert has_element?(page_live, ".entry .content h1", content.screen_name)
      assert has_element?(page_live, ".entry .content h2", content.text)

      assert disconnected_html =~ content.text
      assert render(page_live) =~ content.text
    end

    test "it can filter by type", %{conn: conn, content: content} do
      {:ok, page_live, disconnected_html} = live(conn, "/?type=github_star")

      refute has_element?(page_live, ".entry .content h1", content.screen_name)
      refute has_element?(page_live, ".entry .content h2", content.text)

      refute disconnected_html =~ content.text
      refute render(page_live) =~ content.text

      rendered_html =
        page_live
        |> render_patch("?type=twitter_fav")

      assert has_element?(page_live, ".entry .content h1", content.screen_name)
      assert has_element?(page_live, ".entry .content h2", content.text)

      assert rendered_html =~ content.text
      assert render(page_live) =~ content.text
    end

    test "search resets filters", %{conn: conn, content: content} do
      {:ok, page_live, disconnected_html} = live(conn, "/?type=github_star")

      refute has_element?(page_live, ".entry .content h1", content.screen_name)
      refute has_element?(page_live, ".entry .content h2", content.text)

      refute disconnected_html =~ content.text
      refute render(page_live) =~ content.text

      page_live
      |> element(".filters")
      |> render_change(%{q: "dialyzex"})

      assert has_element?(page_live, ".entry .content h1", content.screen_name)
      assert has_element?(page_live, ".entry .content h2", content.text)
    end

    test "search supports queries with spaces", %{conn: conn, content: content} do
      {:ok, page_live, disconnected_html} = live(conn, "/?type=github_star")

      refute has_element?(page_live, ".entry .content h1", content.screen_name)
      refute has_element?(page_live, ".entry .content h2", content.text)

      refute disconnected_html =~ content.text
      refute render(page_live) =~ content.text

      page_live
      |> element(".filters")
      |> render_change(%{q: "mix task"})

      assert has_element?(page_live, ".entry .content h1", content.screen_name)
      assert has_element?(page_live, ".entry .content h2", content.text)
    end
  end
end
