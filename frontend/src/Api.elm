module Api exposing (..)

import Decode
import Exts.Http exposing (cgiParameters)
import Http
import RemoteData
import Types exposing (..)


baseUrl : String
baseUrl =
    "/"


refresh : Cmd Msg
refresh =
    let
        url =
            baseUrl ++ "refresh"
    in
    Http.get url Decode.refreshStatusDecoder
        |> RemoteData.sendRequest
        |> Cmd.map RefreshResponse


getEntries : PerPage -> Page -> Maybe Source -> Cmd Msg
getEntries perPage page maybeSource =
    let
        typeParams maybeSource =
            case maybeSource of
                Just Twitter ->
                    [ ( "type", "twitter_fav" ) ]

                Just Github ->
                    [ ( "type", "github_star" ) ]

                Just Pinboard ->
                    [ ( "type", "pinboard_link" ) ]

                Nothing ->
                    []

        defaultParams =
            [ ( "per_page", toString perPage )
            , ( "page", toString page )
            ]

        params =
            cgiParameters <| defaultParams ++ typeParams maybeSource

        url =
            baseUrl ++ "entries" ++ "?" ++ params
    in
    Http.get url Decode.entriesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntriesResponse


searchEntries : Query -> Cmd Msg
searchEntries query =
    let
        params =
            cgiParameters [ ( "q", query ) ]

        url =
            baseUrl ++ "entries" ++ "?" ++ params
    in
    Http.get url Decode.entriesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntriesResponse
