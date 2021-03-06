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

# Represents the readable `Subsidiary` NetSuite record.
# |                                            |
# |:-------------------------------------------|
# | id - The internal ID of the record         |
# | externalId - The external ID of the record |
# | links - The HATEOAS links                  |
# | refName - The reference name               |
#
# + name - The name of the `Subsidiary`
# + currency - The base currency used by the `Subsidiary`, which is a mandatory attribute
# + country - The located country
# + email - The return email address
# + isElimination - The elimination state to be used only for journal entries and transactions
# + isInactive - The state of subsidiary record whether its no longer active or used in the account
# + legalName - The legal name of the `Subsidiary` as it should appear on the tax forms
# + url - The subsidiary's Web Site address or URL
public type Subsidiary record {
    *NsResource;
    string name?;
    Currency currency?;
    string country?;
    string email?;
    boolean isElimination?;
    boolean isInactive?;
    string legalName?;
    string url?;
};
