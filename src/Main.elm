module Main exposing (..)

import Array
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
    { filePath : String
    , fileContents : String
    , sortOrder : String
    , dryRun : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { filePath = ""
      , fileContents = ""
      , sortOrder = ""
      , dryRun = False
      }
    , Cmd.none
    )


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

                        dryRun =
                            CLIOptionsParser.getBooleanValue "dry-run" cmd |> Maybe.withDefault False

                        help =
                            CLIOptionsParser.getBooleanValue "help" cmd |> Maybe.withDefault False
                    in
                    if help == True then
                        ( model, H.send <| H.LogToConsole helpContent )

                    else
                        case file of
                            Nothing ->
                                ( model, H.send <| H.LogToConsole "I need a file name mentioned with the --file flag to work." )

                            Just "" ->
                                ( model, H.send <| H.LogToConsole "--file cannot be empty string. I need a valid file name to work with this." )

                            Just f ->
                                ( { model | dryRun = dryRun, filePath = f, sortOrder = sortOrder }, H.send <| H.ReadFile (H.FilePath f) )

                H.ReceiveFileContents contents ->
                    ( { model | fileContents = contents }, Task.perform (\_ -> SortImports) (Task.succeed ()) )

                H.Unknown msgType ->
                    ( model, H.send <| H.LogToConsole ("I receive a command from Node that I did not understand: " ++ msgType) )

        SortImports ->
            let
                sortedImports =
                    sortImportsString model.sortOrder model.fileContents

                newFileContents =
                    Result.map (\( c, n ) -> replaceLines model.fileContents c n) sortedImports
            in
            case newFileContents of
                Ok contents ->
                    let
                        commandToRun =
                            if not model.dryRun then
                                H.WriteToFile (H.FilePath model.filePath)

                            else
                                H.LogToConsole
                    in
                    ( model
                    , Cmd.batch
                        [ H.send <| commandToRun contents
                        ]
                    )

                Err e ->
                    ( model, H.send <| H.LogToConsole e )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ H.harborSubscription |> Sub.map PortMsg
        ]


replaceLines : String -> String -> Int -> String
replaceLines originalContent newContent numOfLines =
    originalContent
        |> String.lines
        |> Array.fromList
        |> (\xs ->
                Array.slice numOfLines (Array.length xs) xs
           )
        |> Array.toList
        |> (\restAsList ->
                List.concat [ String.lines newContent, [ "" ], restAsList ]
           )
        |> String.join "\n"


helpContent =
    """es-sorter

Usage:
--help
Show this help-text.

--file <file_path_with_ext>
Sort the given file. Overwrites the file's import lines. Uses default sort-order (defaults,asterix,objects,none).   

--sort-order <sort-order>
Define a sort order. Has to contain all four types: default, objects, asterix, none. Read the repo documentation for more info. 

--dry-run
Run the script but do not overwrite the file. Instead, print the output to the console/stdout."""
