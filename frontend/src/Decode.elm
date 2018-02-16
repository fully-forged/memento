module Decode exposing (..)

import Exts.Json.Decode exposing (customDecoder, decodeDate)
import Json.Decode as JD
import Types exposing (..)


twitterFavDecoder : JD.Decoder TwitterFav
twitterFavDecoder =
    JD.map5 TwitterFav
        (JD.field "id" JD.string)
        (JD.field "screen_name" JD.string)
        (JD.field "text" JD.string)
        (JD.field "urls" (JD.list JD.string))
        (JD.field "created_at" decodeDate)


pinboardLinkDecoder : JD.Decoder PinboardLink
pinboardLinkDecoder =
    JD.map4 PinboardLink
        (JD.field "id" JD.string)
        (JD.field "href" JD.string)
        (JD.field "description" JD.string)
        (JD.field "time" decodeDate)


githubStarDecoder : JD.Decoder GithubStar
githubStarDecoder =
    JD.map6 GithubStar
        (JD.field "id" JD.string)
        (JD.field "name" JD.string)
        (JD.field "description" JD.string)
        (JD.field "owner" JD.string)
        (JD.field "url" JD.string)
        (JD.field "starred_at" decodeDate)


instapaperBookmarkDecoder : JD.Decoder InstapaperBookmark
instapaperBookmarkDecoder =
    JD.map4 InstapaperBookmark
        (JD.field "id" JD.string)
        (JD.field "title" JD.string)
        (JD.field "url" JD.string)
        (JD.field "time" decodeDate)


contentDecoder : JD.Decoder Content
contentDecoder =
    JD.oneOf
        [ JD.map TwitterContent twitterFavDecoder
        , JD.map PinboardContent pinboardLinkDecoder
        , JD.map GithubContent githubStarDecoder
        , JD.map InstapaperContent instapaperBookmarkDecoder
        ]


entryTypeDecoder : JD.Decoder Source
entryTypeDecoder =
    let
        decodeFun t =
            case t of
                "twitter_fav" ->
                    Ok Twitter

                "pinboard_link" ->
                    Ok Pinboard

                "github_star" ->
                    Ok Github

                "instapaper_bookmark" ->
                    Ok Instapaper

                otherwise ->
                    Err "unsupported content type"
    in
    customDecoder JD.string decodeFun


entryDecoder : JD.Decoder Entry
entryDecoder =
    JD.map4 Entry
        (JD.field "id" JD.string)
        (JD.field "type" entryTypeDecoder)
        (JD.field "content" contentDecoder)
        (JD.field "saved_at" decodeDate)


entriesDecoder : JD.Decoder (List Entry)
entriesDecoder =
    JD.list entryDecoder


refreshStatusDecoder : JD.Decoder RefreshStatus
refreshStatusDecoder =
    JD.succeed Done


statusDecoder : JD.Decoder JD.Value
statusDecoder =
    JD.value
