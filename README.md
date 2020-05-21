[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-netsuite.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-ballerinax-netsuite)
# Ballerina NetSuite Connector

This module allows you to access the NetSuite's SuiteTalk REST Web services API though ballerina. NetSuite is used for 
enterprise resource planning (ERP) and to manage inventory, track their financials, host e-commerce stores and maintain 
customer relationship management (CRM) systems. The NetSuite connector can execute CRUD (create, read, update, delete) 
and search operations to perform business processing on NetSuite records and to navigate dynamically between records.

The following sections provide you details on how to use the NetSuite connector.

- [Compatibility](#compatibility)
- [Getting Started](#getting-started)
- [Samples](#samples)

## Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.x            |
| NetSuite REST API           |            Beta             |

## Getting Started

### Prerequisites
Download and install [Ballerina](https://ballerinalang.org/downloads/).

### Pull the Module
Execute the below command to pull the NetSuite module from Ballerina Central:
```ballerina
$ ballerina pull ballerinax/netsuite
```
## Sample

Instantiate the connector by giving authentication details in the HTTP client config, which has built-in support for 
OAuth 2.0. NetSuite uses OAuth 2.0 to authenticate and authorize requests. The NetSuite connector can be instantiated 
in the HTTP client config using the access token or using the client ID, client secret, and refresh token.

**Obtaining Tokens**

1. Visit [NetSuite](https://www.netsuite.com) and create an Account.
2. Enable SuiteTalk Webservice features of the account (Setup->Company->Enable Features).
3. Obtain SuiteTalk Base URL which contains the account id under company URLs (Setup->Company->Company Information).
    Eg: https://<ACCOUNT_ID>.suitetalk.api.netsuite.com
4. Create an integration application (Setup->Integration->New), enable OAuth 2.0 code grant and scope and obtain the 
following credentials: 
    * Client ID
    * Client Secret
5. Obtain below credentials by following Authorization code Grant Flow in NetSuite documentation. 
    * Access Token
    * Refresh Token
    * Refresh Token URL

**Create the NetSuite client**

```ballerina
// Create NetSuite client configuration by reading from config file.
netsuite:Configuration nsConfig = {
    baseUrl: "<BASE_URL>",
    clientConfig: {
        accessToken: "<ACCESS_TOKEN>",
        refreshConfig: {
            clientId: "<CLIENT_ID>",
            clientSecret: "<CLIENT_SECRET>",
            refreshToken: "<REFRESH_TOKEN>",
            refreshUrl: "<REFRESH_URL>"
        }
    }
};

netsuite:Client nsClient = new(nsConfig);
```

**Perform NetSuite operations**

Following sample shows how NetSuite `Currency` entity can be manipulated

```ballerina
import ballerina/io;
import ballerinax/netsuite;

public function main() {
    netsuite:Currency currency = {
        name: "US Dollar",
        symbol: "USD",
        currencyPrecision: 2,
        exchangeRate: 1.0
    };

    // Create the Currency record in NetSuite and populate passed-in record with id and defaults.
    netsuite:Error? created = nsClient->create(<@untainted> currency);
    if created is netsuite:Error {
        io:println("Error: " + created.detail()?.message.toString());
    }
    io:println("Currency id = " + currency.id);

    // Update the Currency record with displaySymbol
    json symbol = { displaySymbol: "$" };
    netsuite:Error? updated = nsClient->update(<@untainted> currency, symbol);
    if updated is netsuite:Error {
        io:println("Error: " + updated.detail()?.message.toString());
    }
    io:println("Currency displaySymbol = " + currency["displaySymbol"].toString());

    // Check the NetSuite currency record and confirm the update change
    netsuite:ReadableRecord|netsuite:Error retrieved = nsClient->get(<@untainted> currency.id, netsuite:Currency);
    if retrieved is netsuite:Currency {
        io:println("Verify the displaySymbol = " + retrieved["displaySymbol"].toString());
    } else if retrieved is netsuite:Error {
        io:println("Error: " + retrieved.detail()?.message.toString());
    }

    // Upsert(update if exist, otherwise create) a different currency which is used in third party system
    netsuite:Currency externalCurrency = {
        name: "British pound",
        symbol: "GBP",
        currencyPrecision: 2,
        exchangeRate: 1.21753
    };

    netsuite:Error? upserted = nsClient->upsert("163572E", netsuite:Currency, externalCurrency);
    if upserted is netsuite:Error {
        io:println("Error: " + upserted.detail()?.message.toString());
    }
    io:println("External currency id = " + externalCurrency.id);

    // Search for some other popular Currency in the account using a filter
    string[]|netsuite:Error resultId = nsClient->search(netsuite:Currency, "symbol IS LKR");
    if resultId is netsuite:Error {
        io:println("Error: " + resultId.detail()?.message.toString());
    } else {
        io:println("LKR currency id = " + resultId[0]);
    }

    // Delete inserted records
    netsuite:Error? deleted = nsClient->delete(<@untainted> currency);
    if deleted is netsuite:Error {
        io:println("Error: " + deleted.detail()?.message.toString());
    }
}
```