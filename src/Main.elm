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
    | ReceiveInputs ( String, String )
    | SortImports String
    | SendSortedImports String


type alias Model =
    Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( 1, readImportsString "inputs.txt" )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ReceiveInputs ( data, sortString ) ->
            let
                sortedImports =
                    sortImportsString sortString data
            in
            case sortedImports of
                Ok d ->
                    ( model, logSortedImports d )

                Err e ->
                    ( model, logSortedImports e )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveInputs ReceiveInputs
        ]


port receiveInputs : (( String, String ) -> msg) -> Sub msg


port readImportsString : String -> Cmd msg


port saveSortedString : String -> Cmd msg


port logSortedImports : String -> Cmd msg
