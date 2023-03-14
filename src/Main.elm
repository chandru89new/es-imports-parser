port module Main exposing (..)

import OptionsDecoder
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
    | NodeToElm ( String, String )
    | ReceiveCLIString String
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

        NodeToElm ( type_, data ) ->
            case type_ of
                "cli_input" ->
                    ( { model | rawInput = data }, Task.perform ReceiveCLIString (Task.succeed data) )

                "file_contents" ->
                    ( { model | fileContents = data }, Task.perform (\_ -> SortImports) (Task.succeed ()) )

                _ ->
                    ( model, elmToNode ( "log", "I dont know what to do with this type of message coming from Node: type = " ++ type_ ) )

        ReceiveCLIString str ->
            let
                options =
                    OptionsDecoder.parseString str

                file =
                    OptionsDecoder.getValue "file" options
                        |> (\f ->
                                case f of
                                    OptionsDecoder.Str fpath ->
                                        Just (String.trim fpath)

                                    _ ->
                                        Nothing
                           )

                sortOrder =
                    OptionsDecoder.getValue "sort" options
                        |> (\so ->
                                case so of
                                    OptionsDecoder.Str str_ ->
                                        String.trim str_

                                    _ ->
                                        ""
                           )
            in
            case file of
                Nothing ->
                    ( model, elmToNode ( "log", "I need a file name mentioned with the --file flag to work." ) )

                Just "" ->
                    ( model, elmToNode ( "log", "--file cannot be empty string. I need a valid file name to work with this." ) )

                Just f ->
                    ( { model | filePath = f, sortOrder = sortOrder }, elmToNode ( "get_file_contents", f ) )

        SortImports ->
            let
                sortedImports =
                    sortImportsString model.sortOrder model.fileContents
            in
            case sortedImports of
                Ok str ->
                    ( model, elmToNode ( "log", str ) )

                Err e ->
                    ( model, elmToNode ( "log", e ) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ nodeToElm NodeToElm
        ]


port logToConsole : String -> Cmd msg


port elmToNode : ( String, String ) -> Cmd msg


port nodeToElm : (( String, String ) -> msg) -> Sub msg
