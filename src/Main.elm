port module Main exposing (..)

import ImportParser exposing (importsParser, toString)
import Parser exposing (run)
import Sorter exposing (sortImportsString, sortList)
import Task


main =
    Platform.worker
        { subscriptions = subscriptions
        , init = init
        , update = update
        }


type Msg
    = NoOp
    | ReceiveImportsString String
    | SortImports String
    | SaveSortedString String


type alias Model =
    Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( 1, readImportsString "input.txt" )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ReceiveImportsString str ->
            let
                _ =
                    Debug.log "received" str
            in
            ( model, Task.perform SortImports (Task.succeed str) )

        SaveSortedString str ->
            ( model, saveSortedString str )

        SortImports str ->
            let
                res =
                    sortImportsString str
            in
            case res of
                Ok r ->
                    ( model, Task.perform SaveSortedString (Task.succeed r) )

                Err e ->
                    let
                        _ =
                            Debug.log "err" e
                    in
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveImportsString ReceiveImportsString
        ]


port receiveImportsString : (String -> msg) -> Sub msg


port readImportsString : String -> Cmd msg


port saveSortedString : String -> Cmd msg
