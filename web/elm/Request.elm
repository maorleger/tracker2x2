module Request exposing (..)

import Json exposing (..)
import Types exposing (..)
import Http exposing (..)


baseUrl : String
baseUrl =
    "https://tracker2x2.herokuapp.com/api/"


getEpics : RequestParams -> Http.Request (List String)
getEpics { projectId, label, token, userId } =
    let
        epicsUrl =
            baseUrl ++ projectId ++ "/epics?user_id=" ++ toString userId
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
            baseUrl ++ projectId ++ "/stories?epic=" ++ label ++ "&user_id=" ++ toString userId
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
            baseUrl ++ toString params.userId
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
