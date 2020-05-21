// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

type Detail record {
    string message;
    error cause?;
    int statusCode?;
    string errorCode?;
};

# Represents the NetSuite error reason.
public const NETSUITE_ERROR = "(ballerinax/netsuite)Error";

# Represents the NetSuite error type with details.
public type Error error<NETSUITE_ERROR, Detail>;

function getErrorFromError(error errorResponse) returns Error {
    return getError("Error occured during client action", errorResponse);
}

function getError(string errMsg, error errorResponse) returns Error {
    return Error(message = errMsg, cause = errorResponse);
}

function getErrorFromMessage(string errMsg) returns Error {
    return Error(message = errMsg);
}

// {
//     "type": "https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.1",
//     "title": "Invalid reference subsidiary in request body.",
//     "status": 400,
//     "o:errorCode": "INVALID_ID"
// }
function getErrorFromPayload(map<json> errorPayload) returns Error {
    string errMsg = <string> errorPayload["title"];
    int statusCode = <int> errorPayload["status"];
    string errorCode = <string> errorPayload["o:errorCode"];
    return Error(message = errMsg, statusCode = statusCode, errorCode = errorCode);
}
