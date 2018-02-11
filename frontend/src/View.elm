module View exposing (..)

import Date
import Date.Format
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (..)
import String.Extra exposing (ellipsis)
import Types exposing (..)


formatDate : Date.Date -> String
formatDate =
    Date.Format.format "%d-%m-%Y, %H:%M"


contentBlock : Content -> Html Msg
contentBlock content =
    case content of
        TwitterContent tf ->
            div [ class "content" ]
                [ h1 []
                    [ text tf.text ]
                , h2 [] [ text tf.screenName ]
                , ul [] (List.map (\u -> li [] [ a [ href u ] [ text u ] ]) tf.urls)
                ]

        PinboardContent pl ->
            div [ class "content" ]
                [ h1 []
                    [ text pl.description ]
                , p [] [ a [ href pl.href ] [ text (ellipsis 32 pl.href) ] ]
                ]

        GithubContent gs ->
            div [ class "content" ]
                [ h1 []
                    [ text gs.name ]
                , h2 [] [ text gs.description ]
                , p [] [ a [ href gs.url ] [ text gs.url ] ]
                ]

        InstapaperContent ib ->
            div [ class "content" ]
                [ h1 []
                    [ text ib.title ]
                , p [] [ a [ href ib.url ] [ text ib.url ] ]
                ]


icon : Entry -> Html Msg
icon entry =
    case entry.content of
        TwitterContent tf ->
            i [ class "icon-twitter" ] []

        PinboardContent pl ->
            i [ class "icon-pushpin" ] []

        GithubContent gs ->
            i [ class "icon-github" ] []

        InstapaperContent ib ->
            i [ class "icon-instapaper" ] []


entryItem : Entry -> Html Msg
entryItem entry =
    li [ class "entry" ]
        [ header []
            [ icon entry
            , span [ class "date" ] [ text <| formatDate entry.date ]
            ]
        , contentBlock entry.content
        ]


entriesList : List Entry -> Html Msg
entriesList entries =
    ul [ class "entries" ]
        (List.map entryItem entries)


entriesContainer : WebData (List Entry) -> Html Msg
entriesContainer entries =
    case entries of
        NotAsked ->
            div [] []

        Loading ->
            spinner

        Success [] ->
            div [ class "main-error" ]
                [ h1 [] [ text "😔" ]
                , h2 [] [ text "No results for this query" ]
                ]

        Success entries ->
            entriesList entries

        Failure err ->
            div [ class "main-error" ]
                [ h1 [] [ text "😔" ]
                , h2 [] [ text "Network error. See inspector for details" ]
                ]


navBar : Model -> Html Msg
navBar model =
    nav []
        [ div
            [ class "left-nav" ]
            [ span
                [ class "logo"
                , onClick Refresh
                ]
                [ text "M" ]
            , div [ class "source" ]
                [ i
                    [ classList
                        [ ( "icon-twitter", True )
                        , ( "active", model.filterBy == Just Twitter )
                        ]
                    , onClick (FilterBy Twitter)
                    ]
                    []
                , i
                    [ classList
                        [ ( "icon-pushpin", True )
                        , ( "active", model.filterBy == Just Pinboard )
                        ]
                    , onClick (FilterBy Pinboard)
                    ]
                    []
                , i
                    [ classList
                        [ ( "icon-github", True )
                        , ( "active", model.filterBy == Just Github )
                        ]
                    , onClick (FilterBy Github)
                    ]
                    []
                , i
                    [ classList
                        [ ( "icon-instapaper", True )
                        , ( "active", model.filterBy == Just Instapaper )
                        ]
                    , onClick (FilterBy Instapaper)
                    ]
                    []
                , i
                    [ classList
                        [ ( "active", model.filterBy == Nothing )
                        ]
                    , onClick ClearFilter
                    ]
                    [ text "All" ]
                ]
            ]
        , div [ class "filters" ]
            [ input
                [ type_ "search"
                , id "q"
                , name "q"
                , onInput Search
                , value (Maybe.withDefault "" model.query)
                , placeholder "e.g. erlang"
                ]
                []
            ]
        ]


loadMoreBar : Model -> Html Msg
loadMoreBar model =
    let
        content =
            case ( model.entries, model.moreEntries ) of
                ( Success [], _ ) ->
                    []

                ( Success entries, _ ) ->
                    [ button
                        [ onClick LoadMore ]
                        [ text "more" ]
                    ]

                otherwise ->
                    []
    in
        nav [ class "load-more" ]
            content


root : Model -> Html Msg
root model =
    main_ []
        [ navBar model
        , entriesContainer model.entries
        , entriesContainer model.moreEntries
        , loadMoreBar model
        ]


spinner : Html msg
spinner =
    div [ class "spinner" ]
        [ div [ class "rect1" ]
            []
        , div [ class "rect2" ]
            []
        , div [ class "rect3" ]
            []
        , div [ class "rect4" ]
            []
        , div [ class "rect5" ]
            []
        ]
