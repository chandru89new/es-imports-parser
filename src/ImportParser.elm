module ImportParser exposing (..)

import Parser exposing (..)
import Parser.Extras exposing (between, braces)


type alias SourceFile =
    String


type ImportLine
    = DefaultImport ( String, List String ) SourceFile
    | ObjectImport (List String) SourceFile
    | AsterixImport String SourceFile
    | SourceImport String


defaultImportStringParser : Parser ( String, List String )
defaultImportStringParser =
    let
        innerParser =
            succeed identity
                |. chompWhile (\c -> Char.isAlphaNum c || c == '_')
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
    succeed identity
        |. keyword "import"
        |. symbol " "
        |. spaces
        |= oneOf
            [ succeed (\str -> SourceImport str)
                |= sourceFileParser
            , succeed identity
                |= oneOf [ map ObjectImport objectImportStringParser, map AsterixImport asterixImportStringParser, map DefaultImport defaultImportStringParser ]
                |. spaces
                |. keyword "from"
                |. symbol " "
                |= sourceFileParser
            ]
        |. symbol ";"


importsParser : Parser (List ImportLine)
importsParser =
    let
        step : List ImportLine -> Parser (Step (List ImportLine) (List ImportLine))
        step acc =
            let
                finish entry f =
                    case entry of
                        Just val ->
                            f (val :: acc)

                        Nothing ->
                            f acc
            in
            oneOf
                [ succeed finish
                    |= map Just importLineParser
                    |. spacesOnly
                    |= oneOf
                        [ succeed Loop
                            |. symbol "\n"
                        , succeed (Done << List.reverse)
                            |. end
                        ]
                , succeed (Done <| List.reverse acc)
                    |. end
                , succeed (\_ -> finish Nothing Loop)
                    |= symbol "\n"
                , succeed (\_ -> finish Nothing Loop)
                    |= chompIf (\c -> not <| c == '\n')
                    |. spaces
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
        SourceImport s ->
            "import " ++ toSourceString s

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
