module OptionsDecoder exposing (..)

import Dict exposing (Dict)


isOption : String -> Bool
isOption =
    String.startsWith "--"


splitBy : (String -> Bool) -> String -> List String
splitBy fn str =
    let
        split_ =
            String.split "" str

        splitByHelper checker xs state final =
            case xs of
                [] ->
                    List.reverse (state :: final)

                x :: rest ->
                    if checker x then
                        splitByHelper checker rest "" (state :: final)

                    else
                        splitByHelper checker rest (state ++ x) final
    in
    splitByHelper fn split_ "" []


type OptionValue
    = Str String
    | Boolean Bool


type alias Options =
    Dict String OptionValue


parsePair : ( String, String ) -> Options -> Options
parsePair ( fst, snd ) dict =
    if not (isOption fst) then
        dict

    else if not (isOption snd) then
        Dict.insert (String.replace "--" "" fst) (Str snd) dict

    else
        Dict.insert (String.replace "--" "" fst) (Boolean True) dict


parseList : List String -> Options -> Options
parseList xs opts =
    case xs of
        f :: s :: rest ->
            parseList (s :: rest) (parsePair ( f, s ) opts)

        s :: [] ->
            parsePair ( s, "--dummy" ) opts

        [] ->
            opts


parseString : String -> Options
parseString str =
    parseList (splitBy spaceOrEqual str) Dict.empty


spaceOrEqual : String -> Bool
spaceOrEqual =
    \s -> s == " " || s == "="


getValue : String -> Options -> Maybe String
getValue key opts =
    Dict.get key opts
        |> Maybe.andThen
            (\v ->
                case v of
                    Str str ->
                        Just str

                    Boolean _ ->
                        Nothing
            )


getBoolean : String -> Options -> Maybe Bool
getBoolean key opts =
    Dict.get key opts
        |> Maybe.andThen
            (\v ->
                case v of
                    Str _ ->
                        Nothing

                    Boolean val ->
                        Just val
            )
