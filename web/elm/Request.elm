module Request exposing (..)

import Json exposing (..)
import Types exposing (..)
import Http exposing (..)


token : String
token =
    "SomeToken"


getEpics : RequestParams -> Http.Request (List String)
getEpics { projectId, label, token, userId } =
    let
        epicsUrl =
            "http://localhost:4000/api/" ++ projectId ++ "/epics?user_id=" ++ toString userId
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "token" token
                ]
            , url = epicsUrl
            , body = Http.emptyBody
            , expect = Http.expectJson epicsDecoder
            , timeout = Nothing
            , withCredentials = False
            }


getStories : Size -> Size -> RequestParams -> Http.Request (List Story)
getStories board item { projectId, label, token, userId } =
    let
        storiesUrl =
            "http://localhost:4000/api/" ++ projectId ++ "/stories?epic=" ++ label ++ "&user_id=" ++ toString userId
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "token" token
                ]
            , url = storiesUrl
            , body = Http.emptyBody
            , expect = Http.expectJson (storiesDecoder board item)
            , timeout = Nothing
            , withCredentials = False
            }


testEndpoint : RequestParams -> Http.Request String
testEndpoint params =
    let
        testUrl =
            "http://localhost:4000/api?user_id=" ++ toString params.userId
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "token" params.token
                ]
            , url = testUrl
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }
