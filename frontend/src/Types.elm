module Types exposing (..)

import Date exposing (Date)
import RemoteData exposing (..)


type alias Limit =
    Int


type alias Offset =
    Int


type alias Query =
    String


type Source
    = Twitter
    | Pinboard
    | Github


type RefreshStatus
    = Done


type alias Id =
    String


type alias TwitterFav =
    { id : Id
    , screenName : String
    , text : String
    , urls : List String
    , date : Date
    }


type alias PinboardLink =
    { id : Id
    , href : String
    , description : String
    , date : Date
    }


type alias GithubStar =
    { id : Id
    , name : String
    , description : String
    , owner : String
    , url : String
    , date : Date
    }


type Content
    = TwitterContent TwitterFav
    | PinboardContent PinboardLink
    | GithubContent GithubStar


type alias Entry =
    { id : Id
    , entryType : Source
    , content : Content
    , date : Date
    }


type Msg
    = NoOp
    | EntriesResponse (WebData (List Entry))
    | RefreshResponse (WebData RefreshStatus)
    | FilterBy Source
    | ClearFilter
    | LoadMore
    | Refresh
    | Search Query


type alias Model =
    { filterBy : Maybe Source
    , entries : WebData (List Entry)
    , moreEntries : WebData (List Entry)
    , limit : Limit
    , offset : Offset
    , query : Maybe Query
    }
