module Main exposing (..)

import Html exposing (..)
import Markdown exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Mouse exposing (Position)
import Number.Bounded as Bounded exposing (Bounded)
import Http


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
    { trackerToken : String }


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
    , user : Maybe User
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
    in
        ( { stories = stories
          , drag = Nothing
          , axisLock = Y
          , settings = { projectId = "", label = "", token = flags.trackerToken }
          , error = Nothing
          , focusedStory = Nothing
          , user = Nothing
          }
        , Cmd.none
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
    | ChangeAxis Axis
    | Go


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

        Go ->
            ( model, Http.send StoriesResponse (getStories model.settings) )

        Update ProjectId value ->
            let
                settings =
                    model.settings
            in
                ( { model | settings = { settings | projectId = value } }
                , Cmd.none
                )

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
                ( { model | settings = { settings | token = value } }
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
    case model.drag of
        Nothing ->
            Sub.none

        Just _ ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]



-- VIEW


view : Model -> Html Msg
view model =
    if List.isEmpty model.stories then
        div []
            [ h1 [] [ text "Enter your Tracker details" ]
            , Html.form [ onSubmit Go ] <|
                [ input [ onInput <| Update ProjectId, placeholder "Project Id" ] []
                , input [ onInput <| Update Label, placeholder "Label" ] []
                , input [ onInput <| Update Token, placeholder "Token", value model.settings.token ] []
                , input [ type_ "submit", onInput <| Update Token, placeholder "Token" ] []
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
                ]
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
