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


////////////////////////////////////////////
//////// NetSuite subrecords ///////////////
////////////////////////////////////////////
public type AddressBook record {
    string id = "";
    string addressBookType?;
};

public type ItemCollection record {
    Link[] links?;
    ItemElement[] items;
    int totalResults;
    int count?;
    boolean hasMore?;
    int offset?;
};

////////////////////////////////////////////
//////// Common records ////////////////////
////////////////////////////////////////////
public type ItemElement record { //ServiceItem
    string id = "";
    float amount;
    NsResource item;
    string itemSubType?;
    string itemType?;
};

type CommonAttribute record {
    string id = "";
    string externalId?;
    Link[] links?;
    string refName?;
};

public type NsResource record {
    string id = "";
    string externalId?;
    Link[] links?;
    string refName?;
};

public type Link record {
    string rel = "";
    string href = "";
};

// not used ones

public type MainAddress record {
    // Link[] links;
    string id = "";
    string country = "";
    // string addrText?;
    // boolean override?;
};

public type Address record {
    // Link[] links;
    string id = "";
    string country = "";
    string externalId?;
    // string addrText?;
    // boolean override?;
};




