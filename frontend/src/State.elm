module State exposing (..)

import Api
import RemoteData exposing (..)
import Types exposing (..)


initialLimit : Limit
initialLimit =
    25


initialOffset : Offset
initialOffset =
    0


init : ( Model, Cmd Msg )
init =
    ( { filterBy = Nothing
      , entries = Loading
      , moreEntries = NotAsked
      , limit = initialLimit
      , offset = initialOffset
      , query = Nothing
      }
    , Api.getEntries initialLimit initialOffset Nothing
    )


combineEntries : WebData (List Entry) -> WebData (List Entry) -> WebData (List Entry)
combineEntries currentEntries moreEntries =
    case moreEntries of
        Success entries ->
            RemoteData.map (\current -> current ++ entries) currentEntries

        otherwise ->
            currentEntries


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        EntriesResponse resp ->
            case model.moreEntries of
                Loading ->
                    { model | moreEntries = resp } ! []

                otherwise ->
                    { model | entries = resp } ! []

        RefreshResponse resp ->
            case resp of
                Success Done ->
                    update ClearFilter model

                otherwise ->
                    ( model, Cmd.none )

        FilterBy source ->
            ( { model
                | entries = Loading
                , filterBy = Just source
                , offset = initialOffset
              }
            , Api.getEntries model.limit initialOffset (Just source)
            )

        ClearFilter ->
            ( { model
                | entries = Loading
                , filterBy = Nothing
                , offset = initialOffset
              }
            , Api.getEntries model.limit initialOffset Nothing
            )

        LoadMore ->
            ( { model
                | entries = combineEntries model.entries model.moreEntries
                , moreEntries = Loading
                , offset = model.offset + initialLimit
              }
            , Api.getEntries model.limit (model.offset + initialLimit) model.filterBy
            )

        Refresh ->
            ( model
            , Api.refresh
            )

        Search query ->
            let
                newModel =
                    { model
                        | query = Just query
                        , offset = 0
                        , filterBy = Nothing
                        , entries = Loading
                        , moreEntries = NotAsked
                    }
            in
            if String.length query <= 2 then
                ( newModel
                , Api.getEntries newModel.limit newModel.offset newModel.filterBy
                )
            else
                ( newModel
                , Api.searchEntries query
                )
