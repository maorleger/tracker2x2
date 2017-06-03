module Request exposing (..)

import Json exposing (..)
import Types exposing (..)
import Http exposing (..)


token : String
token =
    "SomeToken"


getAvailableLabels : RequestParams -> Http.Request (List String)
getAvailableLabels { projectId, label } =
    let
        epicsUrl =
            "https://www.pivotaltracker.com/services/v5/projects/" ++ projectId ++ "/epics"
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


getStories : Size -> Size -> RequestParams -> Http.Request (List Story)
getStories board item { projectId, label } =
    let
        storiesUrl =
            "https://www.pivotaltracker.com/services/v5/projects/" ++ projectId ++ "/stories?with_label=" ++ label ++ "&fields=name,description"
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "X-TrackerToken" token
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
