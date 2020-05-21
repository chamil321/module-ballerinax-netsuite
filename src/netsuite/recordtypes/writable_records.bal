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
///////////NetSuite records/////////////////
////////////////////////////////////////////

//# Ballerina model to represent the `Customer` entity in NetSuite.
//#
//# + enable - The status of compression
//# + contentTypes - Content types which are allowed for compression
public type Customer record {
    string id = "";
    string entityId = "";
    string companyName = "";
    Subsidiary subsidiary;
    //string externalId = "";
    float balance?;
    boolean isPerson = false;
};

//# Ballerina model to represent the `SalesOrder` entity in NetSuite.
//#
//# + enable - The status of compression
//# + contentTypes - Content types which are allowed for compression
public type SalesOrder record { //done
    *CommonAttribute;
    Entity entity;
    Currency currency;
    ItemCollection item;
    string orderStatus?;
    string trandate?;
    string startDate?;
    string endDate?;
    string otherRefNum?; //PO/Check Number: string
    string memo?;
    string billAddress?;
};

public type Currency record {
    string id = "";
    string name?; //m
    string symbol?; //m
    Link[] links?;
    string externalId?;
    float exchangeRate?;
    int currencyPrecision?;
    boolean isInactive?;
    boolean includeInFxRateUpdates?;
};

public type NonInventoryItem record { // TODO test this record
    string id = "";
    string subtype = "";
    string itemId?;
    NsResource taxSchedule;
    string custitem_product_line?;
    string custitem_item_category?;
    string custitem_quantity_type?;
    string custitem_item_pricing_type?;
};

public type Invoice record {
    *CommonAttribute;
    Entity entity;
    string tranId?;
    AccountingPeriod postingperiod?;
    string trandate?;
    ItemCollection item;
};

public type AccountingPeriod record {
    string id = "";
    Link[] links?;
    string refName?;
    string closedOnDate?;
    string startDate?;
    boolean isQuarter?;
    boolean allLocked?;
    boolean allowNonGLChanges?;
    string endDate;
    boolean arLocked?;
    string periodName?;
};

public type CustomerPayment record {
    *CommonAttribute;
    Customer customer;
    float payment;
    Currency currency;
    Account araccount;
    Account account?;
    float exchangeRate?;
    string customForm?;
    string trandate?;
    AccountingPeriod postingperiod?;
    string memo?;
    float balance?;
    float pending?;
    Subsidiary subsidiary?;
    //nexus
    //entityNexus
    //PaymentMethod
    // subrecord deposit
    // subrecord credit
    // subrecord apply
    // subrecord accountingBookDetail
};

public type Account record {
    *CommonAttribute;
    string acctname?;
    string acctnumber?;
    string accttype?;
    Currency currency?;
    Subsidiary subsidiary?;
};

public type Opportunity record {
    *CommonAttribute;
    Entity entity;
    ItemCollection item;
    string tranId?;
    Partner partner?;
    string titile?;
    Entity salesRep?;
    //CustomerStatus customerStatus?;
    float probability?;
    string expectedCloseDate?;
    NsResource winLossReason?;
    string memo?;
    float projectedtotal?;
    Currency currency?;
    Subsidiary subsidiary?;
};

public type Partner record {
    *CommonAttribute;
    string entityid?;
    string partnerCode?;
    boolean isPerson?;
    string companyName?;
    Partner parent?;
    string url?;
    string category?;
    string comments?;
    Subsidiary subsidiary?;
};


