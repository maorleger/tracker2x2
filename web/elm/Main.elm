module Main exposing (..)

import Html exposing (..)
import Markdown exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Mouse exposing (Position)
import Number.Bounded as Bounded exposing (Bounded)
import Http
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Task


type alias Size =
    { width : Int
    , height : Int
    }


board : Size
board =
    { width = 650, height = 650 }


item : Size
item =
    { width = 90, height = 30 }


type alias ElmFlags =
    { userId : Int
    , trackerToken : String
    }


main : Program ElmFlags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias User =
    { trackerToken : String
    , userName : String
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


type Axis
    = X
    | Y


type Fields
    = ProjectId
    | Label
    | Token


type alias Model =
    { stories : List Story
    , drag : Maybe Drag
    , axisLock : Axis
    , settings : RequestParams
    , error : Maybe String
    , focusedStory : Maybe Story
    , epicLabels : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type alias Drag =
    { id : Int
    , start : Position
    , current : Position
    }


type alias RequestParams =
    { projectId : String
    , label : String
    , token : String
    , editingToken : String
    , userId : Int
    }


init : ElmFlags -> ( Model, Cmd Msg )
init flags =
    let
        middleX =
            (board.width - item.width) // 2

        middleY =
            (board.height - item.height) // 2

        setPosition position =
            Bounded.between 0 (board.width - item.width)
                |> Bounded.set position

        stories =
            []

        initSocket =
            Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
                |> Phoenix.Socket.withDebug
                |> Phoenix.Socket.on "shout" "room:lobby" ReceiveMessage
    in
        ( { stories = stories
          , drag = Nothing
          , axisLock = Y
          , settings = { projectId = "", label = "", token = flags.trackerToken, editingToken = flags.trackerToken, userId = flags.userId }
          , error = Nothing
          , focusedStory = Nothing
          , epicLabels = []
          , phxSocket = initSocket
          }
        , Task.succeed JoinChannel |> Task.perform identity
        )


storyDecoder : Decode.Decoder Story
storyDecoder =
    let
        middleX =
            (board.width - item.width) // 2

        middleY =
            (board.height - item.height) // 2

        setPosition position itemSize =
            Bounded.between 0 (board.width - itemSize)
                |> Bounded.set position
    in
        Decode.map3
            (Story
                { x = setPosition middleX item.width
                , y = setPosition middleY item.height
                }
            )
            (Decode.field "name" Decode.string)
            (Decode.maybe <| Decode.field "description" Decode.string)
            (Decode.field "id" Decode.int)


labelDecoder : Decode.Decoder String
labelDecoder =
    Decode.at [ "label", "name" ] Decode.string


getAvailableLabels : RequestParams -> Http.Request (List String)
getAvailableLabels { projectId, label, token } =
    let
        epicsUrl =
            "https://www.pivotaltracker.com/services/v5/projects/" ++ projectId ++ "/epics"

        labelsDecoder =
            (Decode.list labelDecoder)
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "X-TrackerToken" token
                ]
            , url = epicsUrl
            , body = Http.emptyBody
            , expect = Http.expectJson labelsDecoder
            , timeout = Nothing
            , withCredentials = False
            }


getStories : RequestParams -> Http.Request (List Story)
getStories { projectId, label, token } =
    let
        storiesUrl =
            "https://www.pivotaltracker.com/services/v5/projects/" ++ projectId ++ "/stories?with_label=" ++ label ++ "&fields=name,description"

        storiesDecoder =
            (Decode.list storyDecoder)
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "X-TrackerToken" token
                ]
            , url = storiesUrl
            , body = Http.emptyBody
            , expect = Http.expectJson storiesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


updateToken : Int -> String -> Http.Request ()
updateToken userId token =
    let
        apiUrl =
            "/api/token"

        apiDecoder =
            Decode.succeed ()

        body =
            Http.jsonBody <|
                Encode.object [ ( "user_id", Encode.int userId ), ( "token", Encode.string token ) ]
    in
        Http.request
            { method =
                "POST"
                -- , headers = [ Http.header "Content-Type" "application/json" ]
            , headers = []
            , url = apiUrl
            , body = body
            , expect = Http.expectJson apiDecoder
            , timeout = Nothing
            , withCredentials = False
            }


toPosition : BoundedPosition -> Position
toPosition bp =
    Position (Bounded.value bp.x) (Bounded.value bp.y)



-- UPDATE


type Msg
    = DragStart Int Position
    | DragAt Position
    | DragEnd Position
    | MouseEnter Int
    | MouseLeave Int
    | StoriesResponse (Result Http.Error (List Story))
    | Update Fields String
    | SaveAndSetToken
    | TokenResponse (Result Http.Error ())
    | ChangeEpic String
    | ChangeAxis Axis
    | FetchEpics
    | EpicsResponse (Result Http.Error (List String))
    | Go
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SendMessage
    | ReceiveMessage Encode.Value
    | HandleSendError Encode.Value
    | JoinChannel
    | ShowJoinedMessage String
    | ShowLeftMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragStart _ _ ->
            ( { model | drag = updateDrag msg model.drag }
            , Cmd.none
            )

        DragAt _ ->
            ( { model | drag = updateDrag msg model.drag }
            , Cmd.none
            )

        DragEnd _ ->
            case model.drag of
                Nothing ->
                    ( model, Cmd.none )

                Just drag ->
                    ( { model
                        | stories = List.map (updateStoryPosition model.axisLock model.drag) model.stories
                        , drag = Nothing
                      }
                    , Cmd.none
                    )

        MouseEnter id ->
            ( { model
                | focusedStory =
                    List.head (List.filter (.id >> (==) id) model.stories)
              }
            , Cmd.none
            )

        MouseLeave id ->
            ( { model | focusedStory = Nothing }, Cmd.none )

        ChangeEpic newEpicLabel ->
            let
                settings =
                    model.settings

                newSettings =
                    { settings | label = newEpicLabel }
            in
                ( { model | settings = newSettings }, Http.send StoriesResponse (getStories newSettings) )

        Go ->
            ( model, Http.send StoriesResponse (getStories model.settings) )

        TokenResponse res ->
            ( model, Cmd.none )

        SaveAndSetToken ->
            let
                tokenRequest =
                    1

                settings =
                    model.settings
            in
                ( { model | settings = { settings | token = settings.editingToken } }, Http.send TokenResponse (updateToken settings.userId settings.editingToken) )

        Update ProjectId value ->
            let
                settings =
                    model.settings
            in
                ( { model | settings = { settings | projectId = value } }
                , Cmd.none
                )

        FetchEpics ->
            ( model
            , Http.send EpicsResponse (getAvailableLabels model.settings)
            )

        EpicsResponse result ->
            case result of
                Err error ->
                    ( { model | error = Just <| toString error }, Cmd.none )

                Ok epicLabels ->
                    ( { model | epicLabels = epicLabels }, Cmd.none )

        Update Label value ->
            let
                settings =
                    model.settings
            in
                ( { model | settings = { settings | label = value } }
                , Cmd.none
                )

        Update Token value ->
            let
                settings =
                    model.settings
            in
                ( { model | settings = { settings | editingToken = value } }
                , Cmd.none
                )

        ChangeAxis axis ->
            ( { model | axisLock = axis }, Cmd.none )

        StoriesResponse result ->
            case result of
                Err error ->
                    ( { model | error = Just <| toString error }, Cmd.none )

                Ok stories ->
                    ( { model | stories = stories, error = Nothing }, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        SendMessage ->
            let
                payload =
                    Encode.object
                        [ ( "token", Encode.string model.settings.editingToken )
                        , ( "user_id", Encode.int model.settings.userId )
                        ]

                phxPush =
                    Phoenix.Push.init "new_msg" "room:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveMessage
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
                Phoenix.Socket.withDebug phxSocket
                    |> \socket ->
                        ( { model | phxSocket = socket }, Cmd.map PhoenixMsg phxCmd )

        ReceiveMessage _ ->
            ( model, Cmd.none )

        HandleSendError _ ->
            ( { model | error = Just "Failed to send message" }, Cmd.none )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "room:lobby"
                        |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "room:lobby"))
                        |> Phoenix.Channel.onClose (always (ShowLeftMessage "room:lobby"))

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        ShowJoinedMessage channelName ->
            ( { model | error = Just <| ("Joined channel " ++ channelName) }
            , Cmd.none
            )

        ShowLeftMessage channelName ->
            ( { model | error = Just <| ("Left channel " ++ channelName) }
            , Cmd.none
            )


updateStoryPosition : Axis -> Maybe Drag -> Story -> Story
updateStoryPosition axisLock maybeDrag story =
    case maybeDrag of
        Just drag ->
            if drag.id == story.id then
                { story | position = getPosition axisLock maybeDrag story }
            else
                story

        _ ->
            story


updateDrag : Msg -> Maybe Drag -> Maybe Drag
updateDrag msg drag =
    case msg of
        DragStart id xy ->
            Just
                { id = id
                , start = xy
                , current = xy
                }

        DragAt xy ->
            Maybe.map
                (\drag ->
                    { drag
                        | start = drag.start
                        , current = xy
                    }
                )
                drag

        _ ->
            drag



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        mouseSubscriptions =
            case model.drag of
                Nothing ->
                    Sub.none

                Just _ ->
                    Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]
    in
        Sub.batch [ Phoenix.Socket.listen model.phxSocket PhoenixMsg, mouseSubscriptions ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        optionRenderer labelText =
            option [ value labelText ] [ text labelText ]

        infoRenderer =
            [ h2 [] [ text "Tracker 2x2" ]
            , h3 [] [ text model.settings.label ]
            , div [ class "axis" ]
                [ label [ class "axis__label" ]
                    [ input
                        [ type_ "radio"
                        , name "axis"
                        , class "axis__input"
                        , onClick <| ChangeAxis Y
                        , checked <| model.axisLock == Y
                        ]
                        []
                    , text "Prioritize by importance"
                    ]
                , label [ class "axis__label" ]
                    [ input
                        [ type_ "radio"
                        , name "axis"
                        , class "axis__input"
                        , onClick <| ChangeAxis X
                        , checked <| model.axisLock == X
                        ]
                        []
                    , text "Prioritize by urgency"
                    ]
                ]
            , div [ class "settings" ]
                [ div [ class "settings__project" ]
                    [ h3 [] [ text "Select your project" ]
                    , input
                        [ onInput <| Update ProjectId
                        , placeholder "Project Id"
                        ]
                        []
                    , button [ onClick FetchEpics ] [ text "Fetch Epics" ]
                    ]
                , div [ class "settings__label" ]
                    [ h3 []
                        [ text "Select the epic"
                        ]
                    , select [ onInput ChangeEpic ] <| List.map optionRenderer model.epicLabels
                    ]
                ]
            ]
    in
        if String.isEmpty model.settings.token then
            div []
                [ h1 [] [ text "Whoops! We don't have a tracker token for you" ]
                , h3 [] [ text "Input it below. Don't worry, you will only have to do this once" ]
                , Html.form [ onSubmit SendMessage ] <|
                    [ input [ onInput <| Update Token, placeholder "Token", value model.settings.editingToken ] []
                    , input [ type_ "submit" ] []
                    ]
                        ++ [ h3 [ class "error" ]
                                [ text <|
                                    (Maybe.withDefault "" model.error)
                                ]
                           ]
                ]
        else
            div [ class "container" ]
                [ div [ class "info" ] <|
                    infoRenderer
                        ++ (Maybe.map
                                (\story ->
                                    [ div [ class "story_details" ]
                                        [ h4 [ class "story_details__title" ] [ text story.title ]
                                        , toHtml [ class "story_details__description" ] (Maybe.withDefault "(no description)" story.description)
                                        ]
                                    ]
                                )
                                model.focusedStory
                                |> Maybe.withDefault [ div [ class "story_details story_details--empty" ] [] ]
                           )
                , div
                    [ class "board"
                    , style
                        [ ( "width", px board.width )
                        , ( "height", px board.height )
                        ]
                    ]
                  <|
                    [ div [ class "board__axis board__axis--y" ] []
                    , div [ class "board__axis board__axis--x" ] []
                    ]
                        ++ List.map (itemView model.axisLock model.drag) model.stories
                ]


itemView : Axis -> Maybe Drag -> Story -> Html Msg
itemView axisLock drag story =
    let
        realPosition =
            getPosition axisLock drag story
                |> toPosition
    in
        div
            [ class "item"
            , onMouseDown story.id
            , onMouseEnter story.id
            , onMouseLeave story.id
            , style
                [ ( "left", px realPosition.x )
                , ( "top", px realPosition.y )
                , ( "width", px item.width )
                ]
            ]
            [ text <| "#" ++ toString story.id ]


px : Int -> String
px number =
    toString number ++ "px"


getPosition : Axis -> Maybe Drag -> Story -> BoundedPosition
getPosition axisLock drag story =
    let
        xAxis { id, start, current } =
            if axisLock == X then
                Bounded.set ((Bounded.value story.position.x) + current.x - start.x) story.position.x
            else
                story.position.x

        yAxis { id, start, current } =
            if axisLock == Y then
                Bounded.set ((Bounded.value story.position.y) + current.y - start.y) story.position.y
            else
                story.position.y
    in
        case drag of
            Nothing ->
                story.position

            Just drag ->
                if drag.id == story.id then
                    { x =
                        xAxis drag
                    , y =
                        yAxis drag
                    }
                else
                    story.position


onMouseDown : Int -> Attribute Msg
onMouseDown id =
    on "mousedown" (Decode.map (DragStart id) Mouse.position)


onMouseEnter : Int -> Attribute Msg
onMouseEnter id =
    on "mouseenter" <| Decode.succeed (MouseEnter id)


onMouseLeave : Int -> Attribute Msg
onMouseLeave id =
    on "mouseleave" <| Decode.succeed (MouseLeave id)
