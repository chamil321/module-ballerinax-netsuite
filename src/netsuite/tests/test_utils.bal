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

import ballerina/log;
import ballerina/test;

function createOrSearchIfExist(@tainted WritableRecordType recordValue, string? filter = ()) {
    log:printInfo("-----------create----------------");
    var created = nsClient->create(<@untained> recordValue);
    if (created is Error) {
        log:printInfo(created.toString());
        log:printInfo("-----------So Search for it----------------");
        var searched = nsClient->search(<@untainted>typeof recordValue, filter);
        if (searched is Error) {
            log:printInfo(searched.toString());
            test:assertFail(msg = "search operation failed: " + searched.toString());
            return;
        } else {
            log:printInfo("-----------searched record id----------------");
            log:printInfo(searched[0]);
            recordValue.id = searched[0];
            test:assertTrue(recordValue.id != "", msg = "Currency search failed");
        }
    } else {
        log:printInfo("-----------print id----------------");
        log:printInfo(recordValue.id);
        test:assertTrue(recordValue.id != "", msg = "Currency creation failed");
    }
}

function updateAPartOfARecord(@tainted WritableRecordType recordValue, json input, string key, string value) {
    log:printInfo("-----------update a part----------------");
    Error? updated = nsClient->update(<@untainted> recordValue, input);
    if updated is Error {
        log:printInfo(updated.toString());
        test:assertFail(msg = " update operation failed: " + updated.toString());
    }
    log:printInfo(recordValue[key].toString());
    test:assertTrue(recordValue[key].toString() == value, msg = "update failed");
}

function updateCompleteRecord(@tainted WritableRecordType recordValue, WritableRecordType newValue, string key,
                                  string value) {
    log:printInfo("-----------update a full record----------------");
    Error? updateCustom = nsClient->update(<@untainted> recordValue, <@untained> newValue);
    if updateCustom is Error {
        log:printInfo(updateCustom.toString());//d
        test:assertFail(msg = "update operation failed: " + updateCustom.toString());
    }
    log:printInfo(recordValue[key].toString());
    test:assertTrue(recordValue[key].toString() == value, msg = "update failed");
}

function deleteRecordTest(@tainted WritableRecordType recordValue) {
    // Delete records
    log:printInfo("-----------delete---------");
    var deleteCus = nsClient->delete(recordValue);
    if deleteCus is Error {
        log:printInfo(deleteCus.toString());
        test:assertFail(msg = "delete operation failed: " + deleteCus.toString());
    } else {
        var res = nsClient->get(recordValue.id, typeof recordValue);
        if (res is Error) {
            log:printInfo(res.toString());
            test:assertTrue(res.detail()["errorCode"].toString() == "NONEXISTENT_ID", msg = "record deletion failed");
        } else {
            test:assertFail(msg = "delete operation failed: " + res.toString());
        }
    }
}

function upsertCompleteRecord(WritableRecordType newValue, string exId) {
    log:printInfo("-----------Upsert----------------------");
    Error? upserted = nsClient->upsert(exId, typeof newValue, <@untained> newValue);
    if upserted is Error {
        log:printInfo(upserted.toString());//d
        test:assertFail(msg = "upsert operation failed: " + upserted.toString());
    }
    log:printInfo(newValue.id); //d
    test:assertTrue(newValue.id != "", msg = "upsertion failed");
    test:assertTrue(newValue["externalId"] == exId, msg = "upsertion failed");
}

function upsertAPartOfARecord(@tainted WritableRecordType recordValue, json input, string exId, string key, string value) {
    // Upsert record with a json
    log:printInfo("-----------upsert a part----------------"); //d
    Error? upserted = nsClient->upsert(exId, typeof recordValue, input);
    if upserted is Error {
        log:printInfo(upserted.toString());
        test:assertFail(msg = "upsert operation failed: " + upserted.toString());
    }
    // The upsertion with a JSON does not update any local records as it does not take a record as a param. So user
    // should do a get specifically to verify the change
    ReadableRecordType|Error res = nsClient->get(exId, typeof recordValue, EXTERNAL);
    if (res is Error) {
        log:printInfo(res.toString());
        test:assertFail(msg = "access operation failed: " + res.toString());
    } else {
        test:assertTrue(res[key].toString() == value, msg = "upsertion failed");
    }
}

function subRecordTest(@tainted ReadableRecordType recordValue, SubRecordTypedesc subRecordType, string key, string value)  {
    log:printInfo("-----------getSubRecord----------------");
    var subRecord = nsClient->getSubRecord(recordValue, subRecordType);
    if (subRecord is Error) {
        log:printInfo(subRecord.toString());
        test:assertFail(msg = "getSubRecord operation failed: " + subRecord.toString());
    } else {
        log:printInfo(subRecord.toString());
        test:assertTrue(subRecord[key].toString() == value,  msg = "getSubRecord operation failed");
    }
}

function getARandomPrerequisitRecord(ReadableRecordTypedesc recordType, public string? filter = ()) returns
ReadableRecordType? {
    string recordName = getRecordNameFromTypeDescForTests(recordType);
    string[]|Error lists = nsClient->search(recordType, filter);
    if (lists is Error) {
        log:printInfo(lists.toString());
        test:assertFail(msg = "test cannot be proceeded without prerequisite '" + recordName + "':" + lists.toString());
        return;
    } else {
        log:printInfo("-----------print sub id----------------");
        int count = lists.length();
        if (count == 0) {
            test:assertFail(msg = "test cannot be proceeded without prerequisite '" + recordName + "'");
            return;
        }
        log:printInfo("-----------Get subsidiary----------");
        ReadableRecordType|Error getResult = nsClient->get(<@untained> lists[0], recordType);
        if (getResult is Error) {
            log:printInfo(getResult.toString());
            test:assertFail(msg = "test cannot be proceeded without prerequisite '" + recordName + "':"
                                + getResult.toString());
            return;
        } else {
            test:assertTrue(getResult.id != "", msg = "Subsidiary retrieval failed");
            return getResult;
        }
    }
}

function getRecordNameFromTypeDescForTests(ReadableRecordTypedesc recordType) returns string {
    var name = getRecordName(recordType);
     if name is Error {
         return "NON_EXIST";
     } else {
         return name;
     }
}