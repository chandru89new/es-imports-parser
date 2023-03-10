module Tests exposing (..)

import Expect
import ImportParser exposing (..)
import Parser exposing (run)
import Sorter
import Test exposing (..)


unorderedImports : String
unorderedImports =
    """import { errorAwareRequest } from '../utils/error';
import axios from "axios";
import * as axios from "axios";
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
import { Identity, IdentityType } from '../types/identity';
import { Connection } from "../types/connection";
import {
  Workspace,
  WorkspaceConnectionAssociation,
  WorkspaceMod,
  WorkspaceModInstall,
  WorkspaceModVariable,
  WorkspaceUpdatePayload,
} from "../types/workspace";
"""


orderedImports : String
orderedImports =
    """import axios from "axios";
import get from "lodash/get";
import useAnalytics from "../hooks/useAnalytics";
import useAuthorization from "../hooks/useAuthorization";
import useSWR from "swr";
import * as axios from "axios";
import { API_BASE_PATH, asyncRequest, matchMutate, useSteampipeSWR, withIfMatchHeaderConfig } from "./index";
import { Connection } from "../types/connection";
import { errorAwareRequest } from "../utils/error";
import { Identity, IdentityType } from "../types/identity";
import { Workspace, WorkspaceConnectionAssociation, WorkspaceMod, WorkspaceModInstall, WorkspaceModVariable, WorkspaceUpdatePayload } from "../types/workspace";"""


incorrectImports =
    """import * Test from "wherever";
import Test from "someplace";
"""


tests : Test
tests =
    describe "imports parser"
        [ test "imports test" <|
            \_ ->
                unorderedImports
                    |> Sorter.sortImportsString ""
                    |> Expect.equal (Ok orderedImports)
        , test "imports test failing parsing stage" <|
            \_ ->
                incorrectImports
                    |> Sorter.sortImportsString ""
                    |> Result.mapError (\_ -> True)
                    |> Expect.equal (Result.Err True)
        , test "more tests" <|
            \_ ->
                let
                    input =
                        """import ActionGroup from "../../ActionGroup";
import ConnectionHandleForm from "./ConnectionHandleForm";
import CreateButton from "../../forms/CreateButton";
import ErrorMessage from "../../ErrorMessage";
import get from "lodash/get";
import Icon from "../../Icon";
import NeutralButton from "../../forms/NeutralButton";
import SubmitButton from "../../forms/SubmitButton";
import SuccessMessage from "../../SuccessMessage";
import useIdentityConnectionTest from "../../../hooks/useIdentityConnectionTest";
import useAnalytics from "../../../hooks/useAnalytics";
import useAuthorization from "../../../hooks/useAuthorization";
import {
  getCreateConnectionFunction,
  getCreateInitialValues,
  getCreateValidationSchema,
  getCreateValues,
} from "../plugins/common";
import { Transitions } from "../common";
import { useConnectionQuota } from "../../../hooks/useQuotaCheck";
import { useEffect, useState } from "react";
import { useWorkflow } from "../../Workflow/common";
import { validationErrorIcon } from "../../../constants/icons";
import { Form, Formik, useFormikContext } from "formik";
"""

                    output =
                        """import ActionGroup from "../../ActionGroup";
import ConnectionHandleForm from "./ConnectionHandleForm";
import CreateButton from "../../forms/CreateButton";
import ErrorMessage from "../../ErrorMessage";
import get from "lodash/get";
import Icon from "../../Icon";
import NeutralButton from "../../forms/NeutralButton";
import SubmitButton from "../../forms/SubmitButton";
import SuccessMessage from "../../SuccessMessage";
import useAnalytics from "../../../hooks/useAnalytics";
import useAuthorization from "../../../hooks/useAuthorization";
import useIdentityConnectionTest from "../../../hooks/useIdentityConnectionTest";
import { Form, Formik, useFormikContext } from "formik";
import { getCreateConnectionFunction, getCreateInitialValues, getCreateValidationSchema, getCreateValues } from "../plugins/common";
import { Transitions } from "../common";
import { useConnectionQuota } from "../../../hooks/useQuotaCheck";
import { useEffect, useState } from "react";
import { useWorkflow } from "../../Workflow/common";
import { validationErrorIcon } from "../../../constants/icons";"""
                in
                input
                    |> Sorter.sortImportsString ""
                    |> Expect.equal (Ok output)
        , test "test with different order (asterix,objects,defaults)" <|
            \_ ->
                let
                    input =
                        """import ActionGroup from "../../ActionGroup";
import ConnectionHandleForm from "./ConnectionHandleForm";
import CreateButton from "../../forms/CreateButton";
import ErrorMessage from "../../ErrorMessage";
import get from "lodash/get";
import Icon from "../../Icon";
import NeutralButton from "../../forms/NeutralButton";
import SubmitButton from "../../forms/SubmitButton";
import SuccessMessage from "../../SuccessMessage";
import useIdentityConnectionTest from "../../../hooks/useIdentityConnectionTest";
import useAnalytics from "../../../hooks/useAnalytics";
import useAuthorization from "../../../hooks/useAuthorization";
import {
  getCreateConnectionFunction,
  getCreateInitialValues,
  getCreateValidationSchema,
  getCreateValues,
} from "../plugins/common";
import { Transitions } from "../common";
import { useConnectionQuota } from "../../../hooks/useQuotaCheck";
import { useEffect, useState } from "react";
import { useWorkflow } from "../../Workflow/common";
import { validationErrorIcon } from "../../../constants/icons";
import { Form, Formik, useFormikContext } from "formik";
"""

                    output =
                        """import { Form, Formik, useFormikContext } from "formik";
import { getCreateConnectionFunction, getCreateInitialValues, getCreateValidationSchema, getCreateValues } from "../plugins/common";
import { Transitions } from "../common";
import { useConnectionQuota } from "../../../hooks/useQuotaCheck";
import { useEffect, useState } from "react";
import { useWorkflow } from "../../Workflow/common";
import { validationErrorIcon } from "../../../constants/icons";
import ActionGroup from "../../ActionGroup";
import ConnectionHandleForm from "./ConnectionHandleForm";
import CreateButton from "../../forms/CreateButton";
import ErrorMessage from "../../ErrorMessage";
import get from "lodash/get";
import Icon from "../../Icon";
import NeutralButton from "../../forms/NeutralButton";
import SubmitButton from "../../forms/SubmitButton";
import SuccessMessage from "../../SuccessMessage";
import useAnalytics from "../../../hooks/useAnalytics";
import useAuthorization from "../../../hooks/useAuthorization";
import useIdentityConnectionTest from "../../../hooks/useIdentityConnectionTest";"""
                in
                input
                    |> Sorter.sortImportsString "asterix,objects,defaults"
                    |> Expect.equal (Ok output)
        , test "more" <|
            \_ ->
                let
                    input =
                        """import axios from "axios";
import routeConfig from "./config/routes";
import { AnalyticsProvider } from "./hooks/useAnalytics";
import { API_FETCHER, unauthenticatedErrorResponseInterceptor } from "./api";
import { AuthorizationProvider } from "./hooks/useAuthorization";
import { BreakpointProvider } from "./hooks/useBreakpoint";
import ErrorBoundaryModal from "./components/ErrorBoundaryModal";
import { AuthenticationProvider } from "./hooks/useAuthentication";
import { FullHeightThemeWrapper, ThemeProvider } from "./hooks/useTheme";
import { Helmet } from "react-helmet";
import { SWRConfig } from "swr";
import { BrowserRouter, useNavigate, useRoutes } from "react-router-dom";
import { useEffect } from "react";
import { Toast } from "./components/Toast";
"""

                    output =
                        """import axios from "axios";
import ErrorBoundaryModal from "./components/ErrorBoundaryModal";
import routeConfig from "./config/routes";
import { AnalyticsProvider } from "./hooks/useAnalytics";
import { API_FETCHER, unauthenticatedErrorResponseInterceptor } from "./api";
import { AuthenticationProvider } from "./hooks/useAuthentication";
import { AuthorizationProvider } from "./hooks/useAuthorization";
import { BreakpointProvider } from "./hooks/useBreakpoint";
import { BrowserRouter, useNavigate, useRoutes } from "react-router-dom";
import { FullHeightThemeWrapper, ThemeProvider } from "./hooks/useTheme";
import { Helmet } from "react-helmet";
import { SWRConfig } from "swr";
import { Toast } from "./components/Toast";
import { useEffect } from "react";"""
                in
                input
                    |> Sorter.sortImportsString ""
                    |> Expect.equal (Ok output)
        ]


sourceFileParserTests : Test
sourceFileParserTests =
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


parserOrderFromStringTest : Test
parserOrderFromStringTest =
    describe "parser order from string"
        [ test "normal" <|
            \_ ->
                let
                    str =
                        "defaults,objects,asterix"
                in
                str
                    |> Sorter.parseOrderFromString
                    |> Expect.equal (Ok [ Sorter.DefaultImportType, Sorter.ObjectImportType, Sorter.AsterixImportType ])
        , test "empty string" <|
            \_ ->
                ""
                    |> Sorter.parseOrderFromString
                    |> Expect.equal (Ok Sorter.defaultSortOrder)
        ]
