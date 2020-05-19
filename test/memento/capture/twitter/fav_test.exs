defmodule Memento.Capture.Twitter.FavTest do
  use ExUnit.Case, async: true

  alias Memento.Capture.Twitter.Fav

  @api_result %{
    "contributors" => nil,
    "coordinates" => nil,
    "created_at" => "Tue Nov 28 15:36:03 +0000 2017",
    "entities" => %{
      "hashtags" => [],
      "symbols" => [],
      "urls" => [
        %{
          "display_url" => "github.com/comcast/dialyz…",
          "expanded_url" => "https://github.com/comcast/dialyzex",
          "indices" => 'Ja',
          "url" => "https://t.co/CLgZiRapp9"
        }
      ],
      "user_mentions" => []
    },
    "favorite_count" => 1,
    "favorited" => false,
    "geo" => nil,
    "id" => 935_532_750_223_880_194,
    "id_str" => "935532750223880194",
    "in_reply_to_screen_name" => nil,
    "in_reply_to_status_id" => nil,
    "in_reply_to_status_id_str" => nil,
    "in_reply_to_user_id" => nil,
    "in_reply_to_user_id_str" => nil,
    "is_quote_status" => false,
    "lang" => "en",
    "place" => nil,
    "possibly_sensitive" => false,
    "retweet_count" => 0,
    "retweeted" => false,
    "source" =>
      "<a href=\"https://github.com/benbjohnson/scuttlebutt\" rel=\"nofollow\">Scuttlebuttd</a>",
    "text" =>
      "dialyzex - A Mix task for type-checking your Elixir project with dialyzer https://t.co/CLgZiRapp9",
    "truncated" => false,
    "user" => %{
      "protected" => false,
      "id_str" => "705828978414596096",
      "friends_count" => 0,
      "has_extended_profile" => false,
      "followers_count" => 56,
      "following" => nil,
      "default_profile" => true,
      "translator_type" => "none",
      "profile_sidebar_fill_color" => "DDEEF6",
      "id" => 705_828_978_414_596_096,
      "profile_image_url" =>
        "http://pbs.twimg.com/profile_images/705833395796840450/7riDHwEK_normal.jpg",
      "profile_link_color" => "1DA1F2",
      "is_translation_enabled" => false,
      "verified" => false,
      "utc_offset" => nil,
      "profile_sidebar_border_color" => "C0DEED",
      "statuses_count" => 1577,
      "profile_text_color" => "333333",
      "is_translator" => false,
      "lang" => "en",
      "profile_background_image_url_https" => nil,
      "listed_count" => 2,
      "location" => "",
      "contributors_enabled" => false,
      "profile_background_image_url" => nil,
      "created_at" => "Fri Mar 04 18:55:16 +0000 2016",
      "name" => "OSS Elixir",
      "profile_background_color" => "F5F8FA",
      "notifications" => nil,
      "entities" => %{
        "description" => %{"urls" => []},
        "url" => %{
          "urls" => [
            %{
              "display_url" => "github.com/benbjohnson/sc…",
              "expanded_url" => "https://github.com/benbjohnson/scuttlebutt",
              "indices" => [0, 23],
              "url" => "https://t.co/ar6qcMi3Gw"
            }
          ]
        }
      },
      "url" => "https://t.co/ar6qcMi3Gw",
      "profile_background_tile" => false,
      "default_profile_image" => false,
      "description" =>
        "A news feed of open source Elixir repos being talked about on Twitter. Maintained by @benbjohnson.",
      "favourites_count" => 0,
      "geo_enabled" => false,
      "profile_image_url_https" =>
        "https://pbs.twimg.com/profile_images/705833395796840450/7riDHwEK_normal.jpg",
      "profile_use_background_image" => true,
      "time_zone" => nil,
      "follow_request_sent" => nil,
      "screen_name" => "oss_elixir"
    }
  }

  test "content_from_api_result/1" do
    created_at =
      ~N[2017-11-28 15:36:03]
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.truncate(:second)

    assert %{
             id: "935532750223880194",
             text:
               "dialyzex - A Mix task for type-checking your Elixir project with dialyzer https://t.co/CLgZiRapp9",
             screen_name: "oss_elixir",
             urls: ["https://github.com/comcast/dialyzex"],
             created_at: created_at
           } == Fav.content_from_api_result(@api_result)
  end

  test "with media" do
    media = [
      %{
        "display_url" => "pic.twitter.com/gw3oFiADKc",
        "expanded_url" => "https://twitter.com/waneella_/status/949454537579991040/photo/1",
        "id" => 949_454_503_555_796_993,
        "id_str" => "949454503555796993",
        "indices" => [0, 23],
        "media_url" => "http://pbs.twimg.com/tweet_video_thumb/DS0j1y7WkAEccC_.jpg",
        "media_url_https" => "https://pbs.twimg.com/tweet_video_thumb/DS0j1y7WkAEccC_.jpg",
        "sizes" => %{
          "large" => %{"h" => 810, "resize" => "fit", "w" => 540},
          "medium" => %{"h" => 810, "resize" => "fit", "w" => 540},
          "small" => %{"h" => 680, "resize" => "fit", "w" => 453},
          "thumb" => %{"h" => 150, "resize" => "crop", "w" => 150}
        },
        "type" => "photo",
        "url" => "https://t.co/gw3oFiADKc"
      }
    ]

    api_result = put_in(@api_result, ["entities", "media"], media)

    created_at =
      ~N[2017-11-28 15:36:03]
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.truncate(:second)

    assert %{
             id: "935532750223880194",
             text:
               "dialyzex - A Mix task for type-checking your Elixir project with dialyzer https://t.co/CLgZiRapp9",
             screen_name: "oss_elixir",
             urls: [
               "https://github.com/comcast/dialyzex",
               "https://twitter.com/waneella_/status/949454537579991040/photo/1"
             ],
             created_at: created_at
           } == Fav.content_from_api_result(api_result)
  end
end
