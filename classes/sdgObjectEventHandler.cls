/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgObjectEventHandler {

    Public class NameValue
    {
        public string Name;
        public string Value;
    }
    public class AuraResponse
    {
        public boolean isError;
        public string message;
    }

    @AuraEnabled
    public static String DeleteObject(String ObjectID)
    {
        system.debug('Attempting to delete: ' + ObjectID);
        Boolean isDeleted = false;
        AuraResponse ar = new AuraResponse();
        ar.isError = true;
        ar.message = 'Unable to delete this record';

        ID sobjectID = (ID)ObjectID;
        if (Schema.sObjectType.UserRecordAccess.fields.recordid.isaccessible() && Schema.sObjectType.UserRecordAccess.fields.HasDeleteAccess.isaccessible() && Schema.sObjectType.UserRecordAccess.fields.userid.isaccessible() )
        {
            String queryrights = 'select recordid,  HasDeleteAccess	 from UserRecordAccess where recordid = \'' + String.escapeSingleQuotes(ObjectID) + '\' and userid=\'' + UserInfo.getUserId() + '\'';
            UserRecordAccess URA = database.query(queryrights);

            if (URA.HasDeleteAccess)
            {   //can delete this record
                //Now get pointer to sobject
                Schema.SObjectType token = sObjectID.getSObjectType();

                Schema.DescribeSObjectResult dr = token.getDescribe();

                if (dr.isDeletable())
                {   //No need to double check isaccessible for an ID if it's deletable
                    String querydelete =  'SELECT Id FROM ' + dr.getName() + ' WHERE id= \'' + String.escapeSingleQuotes(ObjectID) + '\' limit 1';

                    List<SObject> obj = database.query(querydelete);
                    if (obj.size()==1)
                    {
                        delete (obj);
                        isDeleted = true;
                        ar.isError = false;
                        ar.Message = '';
                    }
                }

            }

            if (!isDeleted)
            {
                ar.isError = false;
                ar.Message = 'You do not have permission to delete this record.';
            }
        }
        return JSON.serialize(ar);
    }


    @AuraEnabled
    public static String GetRecordTypes(String sObjectTypeParam)
    {
        List<NameValue> recordTypes = new List<NameValue>();

        if (Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible())
        {
            List<RecordType> rts = [SELECT Id,Name, DeveloperName FROM RecordType WHERE SobjectType=:sObjectTypeParam order by Name];

            //Get the object type:
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectTypeParam);
            Schema.DescribeSObjectResult res = targetType.getDescribe();
            Map<Id,Schema.RecordTypeInfo> rtMapById = res.getrecordtypeinfosbyId();

            for(RecordType rt : rts)
            {
                system.debug(rt);
                Schema.RecordTypeInfo rtByID =  rtMapById.get(rt.Id);
                if (rtByID.isAvailable())
                {
                    NameValue newNV = new NameValue();
                    newNV.Name = rt.Name;
                    newNV.Value = rt.Id;
                    recordTypes.add(newNV);
                }
            }


        }
        return JSON.serialize(recordTypes);

    }

}