module Tests exposing (..)

import Expect
import ImportParser exposing (..)
import Parser exposing (run)
import Sorter
import Test exposing (..)


unorderedImports : String
unorderedImports =
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


orderedImports : String
orderedImports =
    """import axios from "axios";
import get from "lodash/get";
import useAnalytics from "../hooks/useAnalytics";
import useAuthorization from "../hooks/useAuthorization";
import useSWR from "swr";
import { API_BASE_PATH, asyncRequest, matchMutate, useSteampipeSWR, withIfMatchHeaderConfig } from "./index";
import { Connection } from "../types/connection";
import { errorAwareRequest } from "../utils/error";
import { Identity, IdentityType } from "../types/identity";
import { Workspace, WorkspaceConnectionAssociation, WorkspaceMod, WorkspaceModInstall, WorkspaceModVariable, WorkspaceUpdatePayload } from "../types/workspace";"""


incorrectImports =
    """import * Test from "wherever";
import Test from "someplace";"""


tests : Test
tests =
    describe "imports parser"
        [ test "imports test" <|
            \_ ->
                unorderedImports
                    |> Sorter.sortImportsString
                    |> Expect.equal (Ok orderedImports)
        , test "imports test failing parsing stage" <|
            \_ ->
                incorrectImports
                    |> Sorter.sortImportsString
                    |> Result.mapError (\_ -> True)
                    |> Expect.equal (Result.Err True)
        ]


sourceFileParserTests : Test
sourceFileParserTests =
    only <|
        describe "Source file parser"
            [ test "of type \"swr\"" <|
                \_ ->
                    let
                        string =
                            """"swr";"""
                    in
                    string
                        |> run sourceFileParser
                        |> Expect.equal (Ok "swr")
            , test "of type \"../swr.js\"" <|
                \_ ->
                    let
                        string =
                            """"../swr.js";"""
                    in
                    string
                        |> run sourceFileParser
                        |> Expect.equal (Ok "../swr.js")
            , test "of type \"@/swr\"" <|
                \_ ->
                    let
                        string =
                            """"@/swr";"""
                    in
                    string
                        |> run sourceFileParser
                        |> Expect.equal (Ok "@/swr")
            , test "of type \"with-hyphens_underscores-123swr\"" <|
                \_ ->
                    let
                        string =
                            "\"with-hyphens_underscores-123swr\";"
                    in
                    string
                        |> run sourceFileParser
                        |> Expect.equal (Ok "with-hyphens_underscores-123swr")
            ]
