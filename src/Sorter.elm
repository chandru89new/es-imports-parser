module Sorter exposing (..)

import ImportParser exposing (ImportLine(..), importsParser, toString)
import Parser


sortList : List ImportType -> List ImportLine -> List ImportLine
sortList order xs =
    let
        defaultImports =
            List.filter isDefaultImport xs |> sortDefaults

        objectImports =
            List.filter isObjectImport xs |> sortObjects

        asterixImports =
            List.filter isAsterixImport xs |> sortAsterix

        sourceImports =
            List.filter isSourceImports xs |> sortSourceImports
    in
    List.concatMap
        (\type_ ->
            case type_ of
                DefaultImportType ->
                    defaultImports

                ObjectImportType ->
                    objectImports

                AsterixImportType ->
                    asterixImports

                SourceImportType ->
                    sourceImports
        )
        order


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


isSourceImports : ImportLine -> Bool
isSourceImports impt =
    case impt of
        SourceImport _ ->
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
                            DefaultImport ( file, List.sortBy (\y -> String.toLower y) (List.filter (not << String.isEmpty) ys) ) sf

                        _ ->
                            x
                )
                xs
    in
    List.sortBy
        (\x ->
            case x of
                DefaultImport ( file, _ ) _ ->
                    String.toLower file

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
                    String.toLower file

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
                            ObjectImport (List.sortBy (\y -> String.toLower y) (List.filter (not << String.isEmpty) list)) sourceFileName

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


sortImportsString : String -> String -> Result String String
sortImportsString ordStr str =
    let
        ord =
            parseOrderFromString ordStr
    in
    ord
        |> Result.andThen
            (\order ->
                str
                    |> Parser.run importsParser
                    |> Result.mapError Parser.deadEndsToString
                    |> Result.map (sortList order >> List.map toString >> String.join "\n")
            )


type ImportType
    = SourceImportType
    | DefaultImportType
    | ObjectImportType
    | AsterixImportType


defaultSortOrder : List ImportType
defaultSortOrder =
    [ SourceImportType, DefaultImportType, AsterixImportType, ObjectImportType ]


parseOrderFromString : String -> Result String (List ImportType)
parseOrderFromString str =
    str
        |> String.split ","
        |> List.map String.trim
        |> List.filterMap
            (\s ->
                case s of
                    "defaults" ->
                        Just DefaultImportType

                    "objects" ->
                        Just ObjectImportType

                    "asterix" ->
                        Just AsterixImportType

                    "none" ->
                        Just SourceImportType

                    _ ->
                        Nothing
            )
        |> (\xs ->
                if List.isEmpty xs then
                    Ok defaultSortOrder

                else if
                    List.length xs
                        /= List.length defaultSortOrder
                        || not (List.member DefaultImportType xs && List.member AsterixImportType xs && List.member ObjectImportType xs && List.member SourceImportType xs)
                then
                    Err "Sort string not valid. If you specify a sort order, you need to mention all of the types (and exactly once). e.g. \"objects,asterix,defaults,none\""

                else
                    Ok xs
           )


sortSourceImports : List ImportLine -> List ImportLine
sortSourceImports xs =
    List.sortBy
        (\x ->
            case x of
                SourceImport s ->
                    String.toLower s

                _ ->
                    ""
        )
        xs
