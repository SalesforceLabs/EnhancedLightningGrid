/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public class sdgPreferences {

    public static sdgRequest GenerateRequestWithFilters(SDG sdg, String ParentRecordID, String SDGTag)
    {

        //Create a request:
        SDGRequest req = new SDGRequest();
        req.ParentRecordID = ParentRecordID;
        req.SDGTag = SDGTag;

        system.debug('sdgPreferences:GenerateRequestWithFilters');
        if (sdg.InternalData != null)
        {
            if (sdg.internalData.sUniqueKey!=null)
            {
            //Get the user preferences
            List<sdg_preferences__c> oldpref= [select filters__c from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :sdg.InternalData.sUniqueKey];
            if (oldpref.size()>0)
            {
                try
                {
                    system.debug('sdgPreferences:GenerateRequestWithFilters: retrieving filters');
                    req.filters = (List<SDGFilter>)JSON.deserialize(oldpref[0].filters__c, List<SDGFilter>.class);
                    Map<String, SDGFilter> mpFilters = new Map<String, SDGFilter>();
                    for (SDGFilter filter : req.filters)
                    {
                        mpFilters.put(filter.SDGFieldID, filter);
                    }
                    for(SDGField field : sdg.SDGFields)
                    {
                        if (mpFilters.containsKey(field.ID))
                            field.Preferences = mpFilters.get(field.ID);
                    }

                }
                catch(exception ex)
                {
                    //ignore this - caused by invalid/out of date filters usually
                }
            }
            }
        }
        return req;
    }

    public static void SaveFilters(SDGRequest request, String sUniqueKey)
    {
        //Save the Filters:
        String filters = JSON.serialize(request.Filters);
        Sdg_preferences__c pref = new sdg_preferences__c();
        pref.User__c = UserInfo.getUserId();
        pref.Filters__c = filters;
        pref.sdgKey__c = sUniqueKey;
        if (String.isNotBlank(sUniqueKey))
        {
                try
                {
                    //Can't upsert using multiple columns so delete existing
                    if ( SDGSecurity.canQuery('sdgPreferences:SaveFilters', 'sdg_preferences__c','filters__c,user__c,sdgKey__c', '',sdgNamespaceUtility.GetNamespace(), false))
                    {

                            List<sdg_preferences__c> oldpref= [select id from sdg_preferences__c where user__c = :UserInfo.getUserID() and sdgKey__c = :sUniqueKey];
                            if (Schema.sObjectType.sdg_preferences__c.isDeletable())
                                delete oldpref;
                            if (Schema.sObjectType.sdg_preferences__c.isCreateable())
                                insert pref;
                    }
                }
                catch (DMLException ex)
                {
                    //this is probably a race condition on aura calls so ignore
                    system.debug('sdgPreferences:SaveFilters: DMLException - ignoring');
                }

        }
    }
}