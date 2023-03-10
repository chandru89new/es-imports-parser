module ImportParser exposing (..)

import Parser exposing (..)
import Parser.Extras exposing (between, braces)


type alias SourceFile =
    String


type alias RawLine =
    String


type ImportLine
    = DefaultImport ( String, List String ) SourceFile
    | ObjectImport (List String) SourceFile
    | AsterixImport String SourceFile


defaultImportStringParser : Parser ( String, List String )
defaultImportStringParser =
    let
        innerParser =
            succeed identity
                |. chompWhile Char.isAlphaNum
                |. spaces
                |> getChompedString
                |> andThen (\s -> succeed (String.replace " " "" s))
    in
    succeed (\a b -> ( a, b ))
        |= innerParser
        |= oneOf
            [ succeed identity
                |. spaces
                |. chompIf (\c -> c == ',')
                |. spaces
                |= objectImportStringParser
            , succeed []
            ]


sourceFileParser : Parser String
sourceFileParser =
    oneOf
        [ between
            (chompIf (\c -> c == '"'))
            (chompIf (\c -> c == '"'))
            (chompWhile
                (\c ->
                    Char.isAlphaNum c || c == '.' || c == '/' || c == '~' || c == '@' || c == '_' || c == '-'
                )
                |> getChompedString
            )
        , between
            (chompIf (\c -> c == '\''))
            (chompIf (\c -> c == '\''))
            (chompWhile
                (\c ->
                    Char.isAlphaNum c || c == '.' || c == '/' || c == '~' || c == '@' || c == '_' || c == '-'
                )
                |> getChompedString
            )
        ]


objectImportStringParser : Parser (List String)
objectImportStringParser =
    let
        innerParser =
            succeed ()
                |. chompWhile
                    (\c -> Char.isAlphaNum c || c == ',' || c == ' ' || c == '\n' || c == '_')
                |> getChompedString
                |> andThen (\str -> succeed (String.split "," str |> List.map (String.replace "\n" "" >> String.replace " " "")))
    in
    braces innerParser


asterixImportStringParser : Parser String
asterixImportStringParser =
    let
        innerParser =
            succeed identity
                |. chompWhile Char.isAlphaNum
                |> getChompedString
    in
    succeed identity
        |. keyword "* as"
        |. spaces
        |= innerParser


importLineParser : Parser ImportLine
importLineParser =
    succeed (\f b -> f b)
        |. keyword "import"
        |. symbol " "
        |. spaces
        |= oneOf [ map ObjectImport objectImportStringParser, map AsterixImport asterixImportStringParser, map DefaultImport defaultImportStringParser ]
        |. spaces
        |. keyword "from"
        |. symbol " "
        |= sourceFileParser
        |. symbol ";"


importsParser : Parser (List ImportLine)
importsParser =
    let
        step : List ImportLine -> Parser (Step (List ImportLine) (List ImportLine))
        step acc =
            let
                finish entry f =
                    f (entry :: acc)
            in
            oneOf
                [ succeed finish
                    |= importLineParser
                    |. spacesOnly
                    |= oneOf
                        [ succeed Loop
                            |. symbol "\n"
                        , succeed (Done << List.reverse)
                            |. symbol "\n\n"
                        ]
                , succeed (Done acc)
                    |. oneOf
                        [ succeed identity
                            |. symbol "\n"
                        , succeed identity
                            |. symbol "\n\n"
                        , succeed identity
                            |. end
                        ]
                ]
    in
    loop [] step


spacesOnly : Parser ()
spacesOnly =
    chompWhile (\c -> c == ' ')


toString : ImportLine -> String
toString line =
    let
        toSourceString : String -> String
        toSourceString s =
            "\"" ++ s ++ "\";"
    in
    case line of
        AsterixImport f s ->
            "import * as " ++ f ++ " from " ++ toSourceString s

        ObjectImport xs s ->
            "import { " ++ String.join ", " xs ++ " } from " ++ toSourceString s

        DefaultImport ( f, xs ) s ->
            let
                objImports =
                    if List.isEmpty xs then
                        ""

                    else
                        ", { " ++ String.join ", " xs ++ " }"
            in
            "import " ++ f ++ objImports ++ " from " ++ toSourceString s


correctImports : List String
correctImports =
    [ """import * as whatever from "somewhere";"""
    , "import Test from \"somewhere\";"
    , """import Test, {more} from "somewhere";"""
    , "import Test , { other, one } from \"someplace\";"
    , "import { ok } from \"lodash\";"
    , "import {fine} from \"somewhere\";"
    , """import   Test,   {   ugly   }  from "elsewhere";"""
    , """import This,
    { and,
    more,
    imports } from "elsewhere";"""
    ]


incorrectImports : List String
incorrectImports =
    [ "import {} Test from \"wherever\""
    , "import { test }, { other} from \"wherever\""
    , "import *as Test from \"who\""
    ]


testLine =
    """import { errorAwareRequest } from "../utils/error";
import axios from "axios";
import get from "lodash/get";
import useAnalytics from "../hooks/useAnalytics";
import useAuthorization from "../hooks/useAuthorization";
import useSWR from "swr";
import {
  API_BASE_PATH,
  asyncRequest,
  matchMutate,
  useSteampipeSWR,
  withIfMatchHeaderConfig,
} from "./index";
import { Identity, IdentityType } from "../types/identity";
import { Connection } from "../types/connection";
import {
  Workspace,
  WorkspaceConnectionAssociation,
  WorkspaceMod,
  WorkspaceModInstall,
  WorkspaceModVariable,
  WorkspaceUpdatePayload,
} from "../types/workspace";"""


testLine2 =
    """import {
  Workspace,
  WorkspaceConnectionAssociation,
  WorkspaceMod,
  WorkspaceModInstall,
  WorkspaceModVariable,
  WorkspaceUpdatePayload,
} from "apple.js";"""


importLines =
    String.join "\n" correctImports


result =
    [ [ "Worker" ]
    , [ "error" ]
    ]
        |> List.sortBy
            (\x ->
                case List.head x of
                    Just str ->
                        String.toLower str

                    Nothing ->
                        ""
            )
