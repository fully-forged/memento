module Types exposing (..)

import Date exposing (Date)
import Json.Decode as JD
import RemoteData exposing (..)


type alias PerPage =
    Int


type alias Page =
    Int


type alias Query =
    String


type Source
    = Twitter
    | Pinboard
    | Github
    | Instapaper


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


type alias InstapaperBookmark =
    { id : Id
    , title : String
    , url : String
    , date : Date
    }


type Content
    = TwitterContent TwitterFav
    | PinboardContent PinboardLink
    | GithubContent GithubStar
    | InstapaperContent InstapaperBookmark


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
    | StatusResponse (WebData JD.Value)
    | FilterBy Source
    | ClearFilter
    | LoadMore
    | Refresh
    | Search Query


type alias Model =
    { filterBy : Maybe Source
    , entries : WebData (List Entry)
    , moreEntries : WebData (List Entry)
    , page : Page
    , perPage : PerPage
    , query : Maybe Query
    }
