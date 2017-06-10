module Json exposing (..)

import Json.Decode as Decode exposing (..)
import Number.Bounded as Bounded exposing (Bounded)
import Types exposing (..)


storiesDecoder : Size -> Size -> Decode.Decoder (List Story)
storiesDecoder board item =
    Decode.at [ "stories" ] <|
        (Decode.list (storyDecoder board item))


storyDecoder : Size -> Size -> Decode.Decoder Story
storyDecoder board item =
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


epicsDecoder : Decode.Decoder (List String)
epicsDecoder =
    Decode.at [ "epics" ] <| (Decode.list Decode.string)
