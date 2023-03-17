module Harbor exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type PortInMsg
    = ReceiveCLICommand String
    | ReceiveFileContents String
    | Unknown String


type PortOutMsg
    = LogToConsole String
    | ReadFile FileName
    | WriteToFile FileName String


type FileName
    = FilePath String


type alias User =
    { id : String, name : String }


sendHandler : PortOutMsg -> Encode.Value
sendHandler msg =
    case msg of
        LogToConsole str ->
            Encode.string str

        WriteToFile (FilePath fp) str ->
            Encode.object
                [ ( "FilePath", Encode.string fp )
                , ( "content", Encode.string str )
                ]

        ReadFile (FilePath str) ->
            Encode.string str


receiveHandler : ( String, String ) -> PortInMsg
receiveHandler ( key, jsonString ) =
    case key of
        "ReceiveCLICommand" ->
            ReceiveCLICommand <|
                (Decode.decodeString Decode.string jsonString |> Result.toMaybe |> Maybe.withDefault "")

        "ReceiveFileContents" ->
            ReceiveFileContents <| (Decode.decodeString Decode.string jsonString |> Result.toMaybe |> Maybe.withDefault "")

        _ ->
            Unknown key
