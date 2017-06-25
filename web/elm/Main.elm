module Main exposing (..)

import Html exposing (..)
import Markdown exposing (..)
import Types exposing (..)
import Json.Decode as Decode
import Number.Bounded as Bounded exposing (Bounded)
import Mouse exposing (Position)
import Request
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http


board : Size
board =
    { width = 650, height = 650 }


item : Size
item =
    { width = 90, height = 30 }


type alias Model =
    { stories : List Story
    , drag : Maybe Drag
    , axisLock : Axis
    , error : Maybe String
    , focusedStory : Maybe Story
    , epicLabels : List String
    , settings : RequestParams
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
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
    in
        { stories = stories
        , drag = Nothing
        , axisLock = Y
        , error = Nothing
        , focusedStory = Nothing
        , epicLabels = []
        , settings =
            { projectId = ""
            , label = ""
            , userId = flags.userId
            , token = flags.token
            }
        }
            ! []



-- POSITION BASED STUFF


toPosition : BoundedPosition -> Position
toPosition bp =
    Position (Bounded.value bp.x) (Bounded.value bp.y)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Nothing ->
            Sub.none

        Just _ ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragStart _ _ ->
            { model | drag = updateDrag msg model.drag } ! []

        DragAt _ ->
            { model | drag = updateDrag msg model.drag } ! []

        DragEnd _ ->
            let
                newModel =
                    case model.drag of
                        Nothing ->
                            model

                        Just drag ->
                            { model
                                | stories = List.map (updateStoryPosition model.axisLock model.drag) model.stories
                                , drag = Nothing
                            }
            in
                newModel ! []

        MouseEnter id ->
            { model
                | focusedStory =
                    List.head (List.filter (.id >> (==) id) model.stories)
            }
                ! []

        MouseLeave id ->
            { model | focusedStory = Nothing } ! []

        ChangeAxis axis ->
            { model | axisLock = axis } ! []

        Update ProjectId value ->
            let
                settings =
                    model.settings
            in
                { model | settings = { settings | projectId = value } } ! []

        Update Label value ->
            let
                settings =
                    model.settings
            in
                { model | settings = { settings | label = value } } ! []

        FetchEpics ->
            model ! [ Http.send EpicsResponse (Request.getEpics model.settings) ]

        EpicsResponse result ->
            case result of
                Err error ->
                    { model | error = Just <| toString error } ! []

                Ok epicLabels ->
                    { model | epicLabels = epicLabels, error = Nothing } ! []

        ChangeEpic newEpicLabel ->
            let
                settings =
                    model.settings

                newSettings =
                    { settings | label = newEpicLabel }
            in
                ( { model | settings = newSettings }
                , Http.send StoriesResponse (Request.getStories board item newSettings)
                )

        -- TODO: rename to FetchStories
        Go ->
            model ! [ Http.send StoriesResponse (Request.getStories board item model.settings) ]

        StoriesResponse result ->
            case result of
                Err error ->
                    { model | error = Just <| toString error } ! []

                Ok stories ->
                    { model | stories = stories, error = Nothing } ! []


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
                [ div [ class "settings__project form-inline" ]
                    [ h3 [] [ text "Select your project" ]
                    , input
                        [ onInput <| Update ProjectId
                        , placeholder "Project Id"
                        , class "form-control"
                        , type_ "text"
                        ]
                        []
                    , button [ class "btn btn-primary", onClick FetchEpics ] [ text "Fetch Epics" ]
                    ]
                , div [ class "settings__label" ]
                    [ h3 []
                        [ text "Select the epic"
                        ]
                    , select
                        [ class "settings__epic form-control"
                        , onInput ChangeEpic
                        ]
                      <|
                        (option [ value "" ] [ text "-- Please Select --" ])
                            :: (List.map optionRenderer model.epicLabels)
                    ]
                ]
            ]

        errorRenderer =
            case model.error of
                Nothing ->
                    div [] []

                Just error ->
                    div [ class "error" ] [ text <| toString error ]
    in
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
                    ++ (Maybe.map
                            (\error ->
                                [ div [ class "error_details" ]
                                    [ h4 [ class "error_details__title" ] [ text "Oh oh! we got an error. See below:" ]
                                    , text <| error
                                    ]
                                ]
                            )
                            model.error
                            |> Maybe.withDefault []
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
