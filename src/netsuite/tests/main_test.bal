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

import ballerina/config;
import ballerina/log;
import ballerina/test;

Configuration nsConfig = {
    baseUrl: config:getAsString("BASE_URL"),
    oauth2Config: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: config:getAsString("REFRESH_URL"),
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    },
    secureSocketConfig: {
        trustStore: {
            path: config:getAsString("B7A_HOME") +
                  "/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
};

Client nsClient = new(nsConfig);

//@test:Config {}
function testCustomer() {
    // Search for mandatory field - Subsidiary
    Subsidiary? subsidiary = ();
    string[]|Error lists = nsClient->search(Subsidiary);
    if (lists is Error) {
        log:printInfo(lists.toString());
        test:assertFail(msg = "test cannot be proceeded without Subsidiary : " + lists.toString());
        return;
    } else {
        log:printInfo("-----------print sub id----------------");
        int count = lists.length();
        if (count == 0) {
            test:assertFail(msg = "test cannot be proceeded without Subsidiary");
            return;
        }
        log:printInfo("-----------Get subsidiary----------");
        ReadableRecordType|Error getResult = nsClient->get(<@untained> lists[0], Subsidiary);
        if (getResult is Error) {
            log:printInfo(getResult.toString());
            test:assertFail(msg = "test cannot be proceeded without Subsidiary : " + getResult.toString());
            return;
        } else if (getResult is Subsidiary) {
            subsidiary = getResult;
            log:printInfo("-----------Subsidiary---------");
            test:assertTrue(getResult.id != "", msg = "Subsidiary retrieval failed");
        } else {
            test:assertFail(msg = "test cannot be proceeded without Subsidiary : Incorrect record type retrieved");
            return;
        }
    }

    Subsidiary subs = <Subsidiary> subsidiary;
    Customer customer = {
        entityId:"ballerina",
        companyName: "ballerinalang",
        subsidiary : subs
    };

    // Create customer record
    createOrSearchIfExist(customer, "entityId IS ballerina");

    updateAPartOfARecord(customer, { "creditLimit": 200003.1 }, "creditLimit", "200003.1");
    Customer replaceCustomer = { entityId: "ballerina", companyName: "ballerina.io", "creditLimit": 3002.0, subsidiary: subs };
    updateCompleteRecord(customer, replaceCustomer, "creditLimit", "3002.0");

    Customer newCustomer = { entityId: "ballerinaUpsert", companyName: "ballerina", "creditLimit": 100000.0, subsidiary : subs };
    upsertCompleteRecord(newCustomer, "16835EID");
    upsertAPartOfARecord(newCustomer, { "creditLimit": 13521.0 }, "16835EID", "creditLimit", "13521.0");

    subRecordTest(<@untainted> customer, Address, "totalResults", "0");

    deleteRecordTest(<@untainted> customer);
    deleteRecordTest(<@untainted> newCustomer);
}

//@test:Config {}
function testCurrency() {
    string[]|Error lists = nsClient->search(Currency);
    if (lists is Error) {
        log:printInfo(lists.toString());
        test:assertFail(msg = "test cannot be proceeded without Subsidiary : " + lists.toString());
        return;
    } else {
        log:printInfo("-----------print Currency id----------------");
        int count = lists.length();
        if (count == 0) {
            test:assertFail(msg = "test cannot be proceeded without Currency");
            return;
        }
        log:printInfo("-----------Get Currency----------");
        ReadableRecordType|Error getResult = nsClient->get(<@untained> lists[0], Currency);
        if (getResult is Error) {
            log:printInfo(getResult.toString());
            test:assertFail(msg = "test cannot be proceeded without Currency : " + getResult.toString());
            return;
        } else if (getResult is Currency) {
            log:printInfo("-----------Currency---------");
            log:printInfo(getResult.toString());
            test:assertTrue(getResult.id != "", msg = "Currency retrieval failed");
        } else {
            test:assertFail(msg = "test cannot be proceeded without Currency : Incorrect record type retrieved");
            return;
        }
    }

    Currency currency = {
        name: "BLA",
        symbol: "BLA",
        currencyPrecision: 3,
        exchangeRate: 3.89
    };

    // Create currency record
    createOrSearchIfExist(currency, "name IS BLA");

    updateAPartOfARecord(currency, { "currencyPrecisioun": 4, "symbol" : "BBB" }, "symbol", "BBB");
    Currency replaceCurrency = { name: "BLA", symbol: "BFF", currencyPrecision: 3, exchangeRate: 5.89 };
    updateCompleteRecord(currency, replaceCurrency, "symbol", "BFF");

    Currency newCurrency = { name: "BLB", symbol: "BLB", currencyPrecision: 6, exchangeRate: 52.89 };
    upsertCompleteRecord(newCurrency, "16834EID");
    upsertAPartOfARecord(newCurrency, { "currencyPrecisioun": 4, "symbol" : "BFB" }, "16834EID", "symbol", "BFB");

    deleteRecordTest(<@untainted> currency);
    deleteRecordTest(<@untainted> newCurrency);
}



@test:Config {}
function testSalesOrder() {
    Customer? customer = ();
    var recordCustomer = getARandomPrerequisitRecord(Customer);
    if recordCustomer is Customer {
        customer = recordCustomer;
    }

    Currency? currency = ();
    var recordCurrency = getARandomPrerequisitRecord(Currency, filter = "name IS LKR"); //TODO change this query
    if recordCurrency is Currency {
        currency = recordCurrency;
    }

    ItemElement serviceItem = {
        amount: 39000.0,
        item: {
            "id": "21",
            "refName": "Development Services"
        },
        "itemSubType": "Sale",
        "itemType": "Service"
    };


    SalesOrder salesOrder = {
        billAddress: "ballerina",
        entity: <Customer> customer,
        currency: <Currency> currency,
        item: {
            items: [serviceItem],
            totalResults: 1
        }
    };

     // Create customer record
    createOrSearchIfExist(salesOrder);

    updateAPartOfARecord(salesOrder, { "shipAddress": "Germany" }, "shipAddress", "Germany");
    SalesOrder replaceSalesOrder = { billAddress: "ballerina.io", entity: <Customer> customer, currency: <Currency>
            currency, item: { items: [serviceItem], totalResults: 1 } };
    updateCompleteRecord(salesOrder, replaceSalesOrder, "billAddress", "ballerina.io");

    SalesOrder newSalesOrder = { billAddress: "Denmark", entity: <Customer> customer, currency: <Currency>
            currency, item: { items: [serviceItem], totalResults: 1 } };
    upsertCompleteRecord(newSalesOrder, "16836EID");

    deleteRecordTest(<@untainted> salesOrder);
    deleteRecordTest(<@untainted> newSalesOrder);
}

//@test:Config {}
function testNonInventoryItem() { //TODO to be tested
    NonInventoryItem nonInventoryItem = {
        itemId: "BA Disposal / Sales",
        subtype: "Sales",
        taxSchedule: {
            links: [],
            id: "1",
            refName: "ca"
        }

        //custitem_product_line: "Other",
        //custitem_item_category: "Other",
        //custitem_quantity_type: "Other",
        //custitem_item_pricing_type: "Monthly",
        //"productfeed": {
        //    "links": [
        //        {
        //            "rel": "self",
        //            "href": "https://3883026-sb1.suitetalk.api.netsuite.com/services/rest/record/v1/noninventoryitem/159/productfeed"
        //        }
        //    ]
        //},
        //"sitecategory": {
        //    "links": [
        //        {
        //            "rel": "self",
        //            "href": "https://3883026-sb1.suitetalk.api.netsuite.com/services/rest/record/v1/noninventoryitem/159/sitecategory"
        //        }
        //    ]
        //},
        //"subsidiary": {
        //    "links": [
        //        {
        //            "rel": "self",
        //            "href": "https://3883026-sb1.suitetalk.api.netsuite.com/services/rest/record/v1/noninventoryitem/159/subsidiary"
        //        }
        //    ]
        //},
    };

     // Create customer record
    createOrSearchIfExist(nonInventoryItem);

     //updateAPartOfARecord(customer, { "creditLimit": 200003.1 }, "creditLimit", "200003.1");
     //Customer replaceCustomer = { entityId: "ballerina", companyName: "ballerina.io", "creditLimit": 3002.0, subsidiary: subs };
     //updateCompleteRecord(customer, replaceCustomer, "creditLimit", "3002.0");
     //
     //Customer newCustomer = { entityId: "ballerinaUpsert", companyName: "ballerina", "creditLimit": 100000.0, subsidiary : subs };
     //upsertCompleteRecord(newCustomer, "16835EID");
     //upsertAPartOfARecord(newCustomer, { "creditLimit": 13521.0 }, "16835EID", "creditLimit", "13521.0");
     //
     //subRecordTest(customer, Address, "totalResults", "0");
     //
     //deleteRecordTest(customer);
     //deleteRecordTest(newCustomer);
}

//@test:Config {}
function testInvoice() {
    // Search for mandatory field - Subsidiary
    //Subsidiary? subsidiary = ();
    //string[]|Error lists = nsClient->search(Subsidiary);
    //if (lists is Error) {
    //    log:printInfo(lists.toString());
    //    test:assertFail(msg = "test cannot be proceeded without Subsidiary : " + lists.toString());
    //    return;
    //} else {
    //    log:printInfo("-----------print sub id----------------");
    //    int count = lists.length();
    //    if (count == 0) {
    //        test:assertFail(msg = "test cannot be proceeded without Subsidiary");
    //        return;
    //    }
    //    log:printInfo("-----------Get subsidiary----------");
    //    ReadableRecordType|Error getResult = nsClient->get(<@untained> lists[0], Subsidiary);
    //    if (getResult is Error) {
    //        log:printInfo(getResult.toString());
    //        test:assertFail(msg = "test cannot be proceeded without Subsidiary : " + getResult.toString());
    //        return;
    //    } else if (getResult is Subsidiary) {
    //        subsidiary = getResult;
    //        log:printInfo("-----------Subsidiary---------");
    //        test:assertTrue(getResult.id != "", msg = "Subsidiary retrieval failed");
    //    } else {
    //        test:assertFail(msg = "test cannot be proceeded without Subsidiary : Incorrect record type retrieved");
    //        return;
    //    }
    //}
    //
    //Subsidiary subs = <Subsidiary> subsidiary;
    //Invoic customer = {
    //    entity:"ballerina",
    //    postingperiod: "ballerinalang",
    //    subsidiary : subs
    //};
    //
    ////public type Invoice record {
    ////    *CommonAttribute;
    ////    Entity entity;
    ////    string tranId?;
    ////    AccountingPeriod postingperiod?;
    ////    string trandate?;
    ////    ItemCollection item;
    ////};
    //
    //// Create customer record
    //createOrSearchIfExist(customer, "entityId IS ballerina");
    //
    //updateAPartOfARecord(customer, { "creditLimit": 200003.1 }, "creditLimit", "200003.1");
    //Customer replaceCustomer = { entityId: "ballerina", companyName: "ballerina.io", "creditLimit": 3002.0, subsidiary: subs };
    //updateCompleteRecord(customer, replaceCustomer, "creditLimit", "3002.0");
    //
    //Customer newCustomer = { entityId: "ballerinaUpsert", companyName: "ballerina", "creditLimit": 100000.0, subsidiary : subs };
    //upsertCompleteRecord(newCustomer, "16835EID");
    //upsertAPartOfARecord(newCustomer, { "creditLimit": 13521.0 }, "16835EID", "creditLimit", "13521.0");
    //
    //subRecordTest(<@untainted> customer, Address, "totalResults", "0");
    //
    //deleteRecordTest(<@untainted> customer);
    //deleteRecordTest(<@untainted> newCustomer);
}
