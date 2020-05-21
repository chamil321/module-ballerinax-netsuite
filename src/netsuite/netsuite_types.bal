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
import ballerina/oauth2;

# The configuration used to create a NetSuite `Client`.
#
# + baseUrl - The account specific service URL for SuiteTalk REST web services(Setup > Company > Setup Tasks >
# Company Information, on the Company URLs subtab)
# + oauth2Config - The OAuth2 client configuration
# + secureSocketConfig - The secure connection configuration
# + timeoutInMillis - The maximum time to wait (in milliseconds) for a response before closing the connection
# + retryConfig - The configurations associated with retrying
public type Configuration record {|
    string baseUrl;
    oauth2:DirectTokenConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
    int timeoutInMillis = 60000;
    http:RetryConfig retryConfig?;
|};

# The types of records that support write NetSuite operations such as create, update and delete.
public type WritableRecord Customer|SalesOrder|Currency|NonInventoryItem|Invoice|AccountingPeriod|CustomerPayment|
                               Account|Opportunity|Partner|Classification;
# The types of records that support read NetSuite operations such as read and search.
public type ReadableRecord Customer|SalesOrder|Subsidiary|Currency|NonInventoryItem|Invoice|AccountingPeriod|
                               CustomerPayment|Account|Opportunity|Partner|Classification;
# The types of nested records that reside inside a parent record.
public type SubRecord AddressBook|Currency|ItemCollection|AccountingPeriod;

# The type description of records that support write NetSuite operations.
public type WritableRecordType typedesc<WritableRecord>;
# The type description of records that support read NetSuite operations.
public type ReadableRecordType typedesc<ReadableRecord>;
# The type description of nested records.
public type SubRecordType typedesc<SubRecord>;

# The types of record identifiers.
public type IdType INTERNAL|EXTERNAL;
# The types of HTTP methods that NetSuite API supports.
public type HttpMethod GET|POST|PATCH|DELETE|PUT;
# The types of ItemEntity available and supported.
public type ItemEntity NonInventoryItem;