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
# + timeoutInMillis - The
# + retryConfig - The
public type Configuration record {|
    string baseUrl;
    oauth2:DirectTokenConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
    int timeoutInMillis = 60000;
    http:RetryConfig retryConfig?;
|};

//TODO change the name to WritableRecord
public type WritableRecordType Customer|SalesOrder|Currency|NonInventoryItem|Invoice|AccountingPeriod|CustomerPayment|
                               Account|Opportunity|Partner;

public type ReadableRecordType Customer|SalesOrder|Subsidiary|Currency|NonInventoryItem|Invoice|AccountingPeriod|
                               CustomerPayment|Account|Opportunity|Partner;

public type SubRecordType Address|AddressBook|Currency|ItemCollection|AccountingPeriod; //Address|Contact;

//TODO change the name to WritableRecordType
public type WritableRecordTypedesc typedesc<WritableRecordType>;
public type ReadableRecordTypedesc typedesc<ReadableRecordType>;
public type SubRecordTypedesc typedesc<SubRecordType>;

public type IdType INTERNAL|EXTERNAL;
public type HttpMethod GET|POST|PATCH|DELETE|PUT;

public type Entity Customer|Partner; //vendor, nsResource, employee, contact ]
public type ItemEntity NonInventoryItem; // inventoryItem, nonInventoryItem, serviceItem  [ inventoryItem, nonInventoryItem, serviceItem,
//otherChargeItem, assemblyItem, kitItem, nsResource, discountItem, markupItem, subtotalItem, descriptionItem,
//paymentItem, salesTaxItem, taxGroup, shipItem, downloadItem, giftCertificateItem, subscriptionPlan ]
