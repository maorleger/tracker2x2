module Types exposing (..)

import Number.Bounded as Bounded exposing (Bounded)
import Mouse exposing (Position)
import Http


type alias Flags =
    { userId : Int
    }


type alias Size =
    { width : Int
    , height : Int
    }


type alias BoundedPosition =
    { x : Bounded Int
    , y : Bounded Int
    }


type alias Story =
    { position : BoundedPosition
    , title : String
    , description : Maybe String
    , id : Int
    }


type alias Drag =
    { id : Int
    , start : Position
    , current : Position
    }


type alias RequestParams =
    { projectId : String
    , label : String
    , userId : Int
    }


type Axis
    = X
    | Y


type Fields
    = ProjectId
    | Label


type Msg
    = DragStart Int Position
    | DragAt Position
    | DragEnd Position
    | MouseEnter Int
    | MouseLeave Int
    | StoriesResponse (Result Http.Error (List Story))
    | Update Fields String
    | ChangeEpic String
    | ChangeAxis Axis
    | FetchEpics
    | EpicsResponse (Result Http.Error (List String))
    | Go
