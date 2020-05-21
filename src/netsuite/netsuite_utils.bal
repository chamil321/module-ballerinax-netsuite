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

function getRecordName(ReadableRecordTypedesc|WritableRecordTypedesc|SubRecordTypedesc recordTypedesc)
                                   returns string|Error {
    if (recordTypedesc is typedesc<Customer>) {
        return RECORD_NAME_CUSTOMER;
    } else if (recordTypedesc is typedesc<SalesOrder>) {
        return RECORD_NAME_SALES_ORDER;
    } else if (recordTypedesc is typedesc<Subsidiary>) {
        return RECORD_NAME_SUBSIDIARY;
    } else if (recordTypedesc is typedesc<AddressBook>) {
        return RECORD_NAME_ADDRESSBOOK;
    } else if (recordTypedesc is typedesc<Currency>) {
        return RECORD_NAME_CURRENCY;
    } else if (recordTypedesc is typedesc<NonInventoryItem>) {
        return RECORD_NAME_NON_INVENTORY_ITEM;
    } else if (recordTypedesc is typedesc<ItemCollection>) {
        return RECORD_NAME_ITEM_COLLECTION;
    } else if (recordTypedesc is typedesc<Invoice>) {
        return RECORD_NAME_INVOICE;
    } else if (recordTypedesc is typedesc<AccountingPeriod>) {
        return RECORD_NAME_ACCOUNTING_PERIOD;
    } else if (recordTypedesc is typedesc<CustomerPayment>) {
        return RECORD_NAME_CUSTOMER_PAYMENT;
    } else if (recordTypedesc is typedesc<Account>) {
        return RECORD_NAME_ACCOUNT;
    } else if (recordTypedesc is typedesc<Opportunity>) {
        return RECORD_NAME_OPPORTUNITY;
    } else if (recordTypedesc is typedesc<Partner>) {
        return RECORD_NAME_PARTNER;
    } else {
        return getErrorFromMessage("operation not implemented for " + recordTypedesc.toString());
    }
}


function constructRecord(ReadableRecordTypedesc|WritableRecordTypedesc|SubRecordTypedesc recordTypedesc, json payload)
                         returns ReadableRecordType|WritableRecordType|SubRecordType|error {
    if (recordTypedesc is typedesc<Customer>) {
        return Customer.constructFrom(payload);
    } else if (recordTypedesc is typedesc<SalesOrder>) {
        return SalesOrder.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Subsidiary>) {
        return Subsidiary.constructFrom(payload);
    } else if (recordTypedesc is typedesc<AddressBook>) {
        return AddressBook.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Currency>) {
        return Currency.constructFrom(payload);
    } else if (recordTypedesc is typedesc<NonInventoryItem>) {
        return NonInventoryItem.constructFrom(payload);
    } else if (recordTypedesc is typedesc<ItemCollection>) {
        return ItemCollection.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Invoice>) {
        return Invoice.constructFrom(payload);
    } else if (recordTypedesc is typedesc<AccountingPeriod>) {
        return AccountingPeriod.constructFrom(payload);
    } else if (recordTypedesc is typedesc<CustomerPayment>) {
        return CustomerPayment.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Account>) {
        return Account.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Opportunity>) {
        return Opportunity.constructFrom(payload);
    } else if (recordTypedesc is typedesc<Partner>) {
        return Partner.constructFrom(payload);
    } else {
        return getErrorFromMessage("operation not implemented for " + recordTypedesc.toString());
    }
}

function updatePassedInRecord(http:Client nsclient, string internalId, @tainted WritableRecordType passedInValue) returns
                              @tainted Error? {
    log:printInfo("```````````````````updatePassedInRecord");
    ReadableRecordType|Error nsRecordValue = getRecord(nsclient, internalId, typeof passedInValue, INTERNAL);
    if (nsRecordValue is Error) {
        return getError("NetSuite record updated successful. But local record population failed", nsRecordValue);
    } else if (nsRecordValue is Customer) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is SalesOrder) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is Currency) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is NonInventoryItem) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is Invoice) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is AccountingPeriod) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is CustomerPayment) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is Opportunity) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else if (nsRecordValue is Partner) {
        foreach var [key, val] in nsRecordValue.entries() {
            passedInValue[key] = val;
        }
    } else {
            log:printInfo("```````````````````updatePassedInRecord  - AccountingPeriod");
        Account value = <Account> nsRecordValue;
        foreach var [key, val] in value.entries() {
            passedInValue[key] = val;
        }
    }
}

function getJsonPayload(http:Client nsclient, string resourcePath, string recordName) returns @tainted json|Error {
    http:Response|error response = nsclient->get(resourcePath);
    if response is http:Response {
        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return getError("'" + recordName + "' record retrival failed: Invalid payload", responsePayload);
        } else {
            if (isErrorResponse(response)) {
                return getErrorFromPayload(<map<json>> responsePayload);
            } else {
                return responsePayload;
            }
        }
    } else {
        return getError("'" + recordName + "' record retrival request failed", response);
    }
}

function isErrorResponse(http:Response response) returns boolean {
    if (response.hasHeader("Content-Type")) {
        string contentType = response.getHeader("Content-Type");
        log:printInfo("```````````````````contentType");
        log:printInfo(contentType);
        var value = http:parseHeader(contentType);
        if value is error {
            return false;
        } else {
            var [val, params] = value;
            log:printInfo(params["type"].toString());
            if (params["type"].toString() == "error") {
                return true;
            } else {
                return false;
            }
        }
    }
    return false;
}


