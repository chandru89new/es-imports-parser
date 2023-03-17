module Main exposing (..)

import CLIOptionsParser
import Harbor as H
import HarborGenerated as H
import Sorter exposing (sortImportsString)
import Task


main =
    Platform.worker
        { subscriptions = subscriptions
        , init = init
        , update = update
        }


type Msg
    = NoOp
    | PortMsg H.PortInMsg
    | SortImports


type alias Model =
    { rawInput : String
    , filePath : String
    , fileContents : String
    , sortOrder : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" "" "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PortMsg portInMsg ->
            case portInMsg of
                H.ReceiveCLICommand cmd ->
                    let
                        file =
                            CLIOptionsParser.getStringValue "file" cmd |> Maybe.map String.trim

                        sortOrder =
                            CLIOptionsParser.getStringValue "sort" cmd |> Maybe.map String.trim |> Maybe.withDefault ""
                    in
                    case file of
                        Nothing ->
                            ( model, H.send <| H.LogToConsole "I need a file name mentioned with the --file flag to work." )

                        Just "" ->
                            ( model, H.send <| H.LogToConsole "--file cannot be empty string. I need a valid file name to work with this." )

                        Just f ->
                            ( { model | filePath = f, sortOrder = sortOrder }, H.send <| H.ReadFile (H.FilePath f) )

                H.ReceiveFileContents contents ->
                    ( { model | fileContents = contents }, Task.perform (\_ -> SortImports) (Task.succeed ()) )

                H.Unknown msgType ->
                    ( model, H.send <| H.LogToConsole ("I receive a command from Node that I did not understand: " ++ msgType) )

        SortImports ->
            let
                sortedImports =
                    sortImportsString model.sortOrder model.fileContents
            in
            case sortedImports of
                Ok ( contents, rows ) ->
                    ( model
                    , Cmd.batch
                        [ H.send <| H.WriteToFile (H.FilePath model.filePath) contents rows
                        ]
                    )

                Err e ->
                    ( model, H.send <| H.LogToConsole e )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ H.harborSubscription |> Sub.map PortMsg
        ]
