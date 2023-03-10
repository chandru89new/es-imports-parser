module Sorter exposing (..)

import ImportParser exposing (ImportLine(..), importsParser, toString)
import Parser


sortList : List ImportLine -> List ImportLine
sortList xs =
    let
        defaultImports =
            List.filter isDefaultImport xs

        objectImports =
            List.filter isObjectImport xs

        asterixImports =
            List.filter isAsterixImport xs
    in
    List.concat [ sortDefaults defaultImports, sortAsterix asterixImports, sortObjects objectImports ]


isDefaultImport : ImportLine -> Bool
isDefaultImport impt =
    case impt of
        DefaultImport _ _ ->
            True

        _ ->
            False


isObjectImport : ImportLine -> Bool
isObjectImport impt =
    case impt of
        ObjectImport _ _ ->
            True

        _ ->
            False


isAsterixImport : ImportLine -> Bool
isAsterixImport impt =
    case impt of
        AsterixImport _ _ ->
            True

        _ ->
            False


sortDefaults : List ImportLine -> List ImportLine
sortDefaults xs =
    let
        sortedInternals =
            List.map
                (\x ->
                    case x of
                        DefaultImport ( file, ys ) sf ->
                            -- ys could have empty strings in the list so we need to remove those
                            DefaultImport ( file, List.sort (List.filter (not << String.isEmpty) ys) ) sf

                        _ ->
                            x
                )
                xs
    in
    List.sortBy
        (\x ->
            case x of
                DefaultImport ( file, _ ) _ ->
                    file

                _ ->
                    ""
        )
        sortedInternals


sortAsterix : List ImportLine -> List ImportLine
sortAsterix =
    List.sortBy
        (\x ->
            case x of
                AsterixImport file _ ->
                    file

                _ ->
                    ""
        )


sortObjects : List ImportLine -> List ImportLine
sortObjects xs =
    let
        sortedInternals =
            List.map
                (\x ->
                    case x of
                        ObjectImport list sourceFileName ->
                            -- list could have empty strings so need to filter them out before sorting
                            ObjectImport (List.sort (List.filter (not << String.isEmpty) list)) sourceFileName

                        _ ->
                            x
                )
                xs
    in
    List.sortBy
        (\x ->
            case x of
                ObjectImport list _ ->
                    case List.head list of
                        Just str ->
                            String.toLower str

                        Nothing ->
                            ""

                _ ->
                    ""
        )
        sortedInternals


sortImportsString : String -> Result (List Parser.DeadEnd) String
sortImportsString str =
    str
        |> Parser.run importsParser
        |> Result.map (sortList >> List.map toString >> String.join "\n")
