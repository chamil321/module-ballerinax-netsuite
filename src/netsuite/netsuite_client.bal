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

import ballerina/http;
import ballerina/log;
import ballerina/oauth2;
import ballerina/stringutils;

public type Client client object {
    private http:Client netsuiteClient;

    public function __init(Configuration netSuiteConfig) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new (netSuiteConfig.oauth2Config);
        http:BearerAuthHandler bearerHandler = new (oauth2Provider);

        http:ClientConfiguration httpClientConfig = {
            auth: {
                authHandler: bearerHandler
            },
            secureSocket: netSuiteConfig?.secureSocketConfig,
            timeoutInMillis: netSuiteConfig.timeoutInMillis,
            retryConfig: netSuiteConfig?.retryConfig,
            http1Settings: {
                keepAlive: http:KEEPALIVE_NEVER
            }
        };

        self.netsuiteClient = new(netSuiteConfig.baseUrl, httpClientConfig);
    }

    # Creates the NetSuite record and populates the passed-in record.
    #
    # + value - The value that needs to be inserted as a NetSuite record
    # + return - The `netSuite:Error` if it is a failure or else `()`
    public remote function create(@tainted WritableRecordType value) returns @tainted Error? {
        return createRecord(self.netsuiteClient, value);
    }

    # Retrieves the NetSuite record for a given internal/external identifier. Relevant record is uniquely identified
    # by the record type and id
    #
    #
    # + id - The internal/external identifier
    # + targetType - The typedesc of targeted record type
    # + idType - The type of the provided record identifier
    # + return - The `netSuite:Error` if it is a failure or else the record
    public remote function get(string id, ReadableRecordTypedesc targetType, public IdType idType = INTERNAL) returns
                               @tainted ReadableRecordType|Error {
        return getRecord(self.netsuiteClient, id, targetType, idType);
    }

    # Updates the NetSuite record with the given values.
    #
    # + existingValue - The original NetSuite record
    # + newValue - The record or a part of record which needs to be replaced with
    # + return - The `netSuite:Error` if it is a failure or else `()`
    public remote function update(@tainted WritableRecordType existingValue, WritableRecordType|json newValue) returns
                                  @tainted Error? {
        return updateRecord(self.netsuiteClient, existingValue, newValue);
    }

    # Deletes the given record from NetSuite.
    #
    # + value - The record that needs to be deleted from NetSuite
    # + return - The `netSuite:Error` if it is a failure or else `()`
    public remote function delete(WritableRecordType value) returns @tainted Error? {
        return deleteRecord(self.netsuiteClient, value);
    }

    # Creates the NetSuite record or updates an existing record using external id. Relevant record is uniquely
    # identified by the record type and externalId
    #
    # + externalId - The external identifier
    # + targetType - The typedesc of targeted record type
    # + value - The record or a part of a record, which needs to be created or updated
    # + return - The `netSuite:Error` if it is a failure or else `()` if created/updated
    public remote function upsert(string externalId, WritableRecordTypedesc targetType, WritableRecordType|json value) 
                                  returns @tainted Error? {
        return upsertRecord(self.netsuiteClient, targetType, externalId, value);
    }

    # Retrieves the list of records ids. The list can be filtered with given filter string.
    #
    # + targetType - The typedesc of targeted record type
    # + filter - The condition to filter the list using operators. Each condition consists of a field name, an
    #            operator, and a value. Several conditions can be joined using the AND / OR logical operators
    #            Eg:"id BETWEEN_NOT[1,42]", "dateCreated ON_OR_AFTER1/1/2019 AND dateCreated BEFORE 1/1/2020",
    # + return - The `netSuite:Error` if it is a failure or else an array of string ids
    public remote function search(ReadableRecordTypedesc targetType, public string? filter = ()) returns @tainted
                                  string[]|Error {
        return searchRecord(self.netsuiteClient, targetType, filter);
    }

    # Retrieves the nested records of NetSuite record.
    #
    # + parent - The parent record of subrecord
    # + subRecordType - The typedesc of targeted record type
    # + return - The `netSuite:Error` if it is a failure or else the nested record
    public remote function getSubRecord(ReadableRecordType parent, SubRecordTypedesc subRecordType) returns @tainted
                                        SubRecordType|Error {
        string parentRecordName = check getRecordName(typeof parent);
        string recordId = parent.id;
        if (recordId == "") {
            return getErrorFromMessage("internal id not found : record '" + parentRecordName + "'");
        }
        string subRecordName = check getRecordName(subRecordType);
        string resourcePath = REST_RESOURCE + parentRecordName + "/" + recordId + "/" + subRecordName + EXPAND_SUB_RESOURCES;
        
        json payload = check getJsonPayload(self.netsuiteClient, resourcePath, subRecordName);
        var result =  constructRecord(subRecordType, payload);
        if result is error {
            return getError("'" + subRecordName + "' subrecord mapping failed", result);
        } else if result is WritableRecordType|ReadableRecordType {
            panic getErrorFromMessage("illegal state error");
        } else {
            return result;
        }
    }

    # Common action to execute all queries including custom records in a generic manner. This action can be use as an
    # alternative for unsupported entities and actions. The metadata can be accessed via <LINK_API_DOCS>
    #
    # + httpMethod - The respective API method
    # + path - The resource path including path and query params(eg:"/customer/{id}/!transform/vendor")
    # + requestBody - The json typed request body
    # + return - A `netSuite:Error` if it is a failure or the response body. If the response status code is a 204,
    #            headers will be returned as a JSON
    public remote function execute(HttpMethod httpMethod, string path, public json? requestBody = ()) returns
                                   @tainted json|Error {
        http:Response|error response = self.netsuiteClient->execute(httpMethod, path, requestBody);
        if response is http:Response {
            if (response.statusCode == 204) {
                map<json> j = {};
                foreach string key in response.getHeaderNames() {
                    j[key] = response.getHeader(<@untainted> key);
                }
                return j;
            }
            json|error responsePayload = response.getJsonPayload();
            if responsePayload is error {
                return getError("payload retrival failed: Invalid payload", responsePayload);
            } else {
                if (isErrorResponse(response)) {
                    return getErrorFromPayload(<map<json>> responsePayload);
                } else {
                    return responsePayload;
                }
            }
        } else {
            return getError("execution failed", response);
        }
    }
};

function createRecord(http:Client nsclient, @tainted WritableRecordType recordValue) returns @tainted Error? {
    string recordName = check getRecordName(typeof recordValue);

    json|error payload = json.constructFrom(recordValue);
    if payload is error {
        return getError("Error while constructing request payload for create operation", payload);
    }
    json jsonValue = <json> payload;

    http:Response|error response = nsclient->post(REST_RESOURCE + recordName, jsonValue);
    if response is http:Response {
        if (response.statusCode == 204 && response.hasHeader("Location")) {
            string locationHeader = response.getHeader("Location");
            string[] directives = stringutils:split(locationHeader, "/");
            string internalId = directives[directives.length() - 1];
            check updatePassedInRecord(nsclient, internalId, recordValue);
            return ();
        }
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record creation failed", responsePayload);
        } else {
            return getErrorFromPayload(<map<json>> responsePayload);
        }
    } else {
        return getError("'" + recordName + "' record creation request failed", response);
    }
}

function getRecord(http:Client nsclient, string id, ReadableRecordTypedesc targetType, IdType idType = INTERNAL)
                   returns @tainted ReadableRecordType|Error {
    string targetRecordName = check getRecordName(targetType);
    string recordId = "/" + (idType is INTERNAL ? id : EID + id);
    string resourcePath = REST_RESOURCE + targetRecordName + recordId + EXPAND_SUB_RESOURCES;
    log:printInfo(resourcePath);
    json payload = check getJsonPayload(nsclient, resourcePath, targetRecordName);
    log:printInfo("------------------Retrieved payload");
    log:printInfo(payload.toString());
    var result =  constructRecord(targetType, payload);
    if result is ReadableRecordType {
        return result;
    } else if result is error {
        return getError("'" + targetRecordName + "' record mapping failed", result);
    } else {
        panic getErrorFromMessage("illegal state error get operation");
    }
}

function updateRecord(http:Client nsclient, @tainted WritableRecordType existingValue, WritableRecordType|json newValue)
                      returns @tainted Error? {
    string recordName = check getRecordName(typeof existingValue);
    string recordId = existingValue.id;
    if (recordId == "") {
        return getErrorFromMessage("internal id not found : record '" + recordName + "'");
    }
    json payload;

    if newValue is WritableRecordType {
        json|error jsonValue = json.constructFrom(newValue);
        if jsonValue is error {
            return getError("Error while constructing request payload for update operation", jsonValue);
        }
        payload = <json> jsonValue;
    } else {
        payload = newValue;
    }

    http:Response|error response = nsclient->patch(REST_RESOURCE + recordName + "/" + recordId, payload);
    if response is http:Response {
        if (response.statusCode == 204 && response.hasHeader("Location")) {
                    log:printInfo("updateRecord response.statusCode == 204");
            check updatePassedInRecord(nsclient, recordId, existingValue);
            return ();
        }
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record update failed", responsePayload);
        } else {
            return getErrorFromPayload(<map<json>> responsePayload);
        }
    } else {
        return getError("'" + recordName + "' record update request failed", response);
    }
}

function deleteRecord(http:Client nsclient, WritableRecordType value) returns @tainted Error? {
    string recordName = check getRecordName(typeof value);
    string id = value.id;
    if (id == "") {
        return getErrorFromMessage("internal id not found : record '" + recordName + "'");
    }

    http:Response|error response = nsclient->delete(REST_RESOURCE + recordName + "/" + id);
    if response is http:Response {
        if (response.statusCode == 204) {
            return ();
        }
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record deletion failed", responsePayload);
        } else {
            return getErrorFromPayload(<map<json>> responsePayload);
        }
    } else {
        return getError("'" + recordName + "' record deletion request failed", response);
    }
}

function upsertRecord(http:Client nsclient, WritableRecordTypedesc targetType, string recordId, WritableRecordType|json newValue)
                      returns @tainted Error? {
    string recordName = check getRecordName(targetType);
    json payload;

    if newValue is WritableRecordType {
        json|error jsonValue = json.constructFrom(newValue);
        if jsonValue is error {
            return getError("Error while constructing request payload for upsert operation", jsonValue);
        }
        payload = <json> jsonValue;
    } else {
        payload = newValue;
    }

    http:Response|error response = nsclient->put(REST_RESOURCE + recordName + "/" + EID + recordId, payload);
    if response is http:Response {
        if (response.statusCode == 204 && response.hasHeader("Location")) {
            if newValue is WritableRecordType {
                string locationHeader = response.getHeader("Location");
                string[] directives = stringutils:split(locationHeader, "/");
                string internalId = directives[directives.length() - 1];
                check updatePassedInRecord(nsclient, internalId, newValue);
            }
            return ();
        }
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record upsertion failed", responsePayload);
        } else {
            return getErrorFromPayload(<map<json>> responsePayload);
        }
    } else {
        return getError("'" + recordName + "' record upsertion request failed", response);
    }
}

function searchRecord(http:Client nsclient, ReadableRecordTypedesc targetType, string? filter) returns @tainted
                      string[]|Error {
    string recordName = check getRecordName(targetType);
    string queryStr = filter is () ? "" : "?q=" + filter;
    log:printInfo("query : " + queryStr);
    http:Response|error initialResponse = nsclient->get(REST_RESOURCE + recordName + queryStr);
    if (initialResponse is error) {
        return getError("'" + recordName + "' record search() request failed", initialResponse);
    }
    http:Response response = <http:Response> initialResponse;
    if (response.statusCode != 200) {
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record search failed", responsePayload);
        } else {
            return getErrorFromPayload(<map<json>> responsePayload);
        }
    }

    json|error responsePayload = response.getJsonPayload();
    if responsePayload is error {
        return getError("'" + recordName + "' record search failed", responsePayload);
    }
    map<json> listOfItem = <map<json>> responsePayload;
    json|error hasMore = listOfItem.hasMore;
    if hasMore is error {
        return getError("Invalid content failed", hasMore);
    }
    string[] collection = [];
    boolean hasMoreData = <boolean> hasMore;
    //if (hasMoreData) {
    //    //TODO iterate
    //    log:printInfo(" hasMoreData -Iterate, not implemeted");
    //    collection.push("Iterate, not implemeted");
    //    return collection;
    //} else {
        log:printInfo(" no MoreData");
        json[] items = <json[]> listOfItem["items"];
        foreach json item in items {
            map<json> j = <map<json>> item;
            collection.push(j["id"].toString());
        }
        if (collection.length() == 0) {
            return getErrorFromMessage("No results found");
        }
        return collection;
    //}
}


