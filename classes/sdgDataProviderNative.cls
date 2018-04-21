/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgDataProviderNative implements sdgIDataProvider {
    global static Boolean isUserSelectable()
    {
        return false;
    }
    global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {
        
        SDGResult result =  sdgQueryEngine.getSDGResultRaw(CoreSDG, request);
        return result;
    }
    
    global   SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        SDG CoreSDG = null;
        
        sdgSecurity.CanQuery('sdgDataProviderNative:LoadSDG', 'SDG__c', 'sobjectname__c, parent_field_name__c, filter__c, default_sort__c, is_valid__c, All_Rows__c, DisableSharing__c', 'Id', sdgNamespaceUtility.GetNamespace(), true);
        sdgSecurity.CanQuery('sdgDataProviderNative:GetSDGActions' , 'SDG_Action__c', 'event__c, action_order__c, Requires_Createable__c, requires_deletable__c, Requires_Editable__c, Action_Type__c, Event_Payload__c, Icon__c', 'id,name', sdgNamespaceUtility.GetNamespace(), true);
        sdgSecurity.CanQuery('sdgDataProviderNative:GetSDGFields', 'SDG_Field__c', 'apiname__c,  FieldOrder__c, Field_Style__c, Hide_Filter__c, Override_Label__c', 'id,name', sdgNamespaceUtility.GetNamespace(), true);
        
        List<SDG__c> sdgs= [select id, sobjectname__c, parent_field_name__c, filter__c, default_sort__c, is_valid__c, All_Rows__c, DisableSharing__c, (select id, name, event__c, Requires_Createable__c, Requires_Editable__c, requires_deletable__c, Action_Type__c, Event_Payload__c, Icon__c, action_order__c  from sdg_actions__r), (select id, name, apiname__c,  FieldOrder__c, Field_Style__c, Hide_Filter__c, Override_Label__c  from SDGFields__r where is_valid_field__c =true) from SDG__c where SDG_Tag__c = :SDGTag ];
        if (sdgs.size()!=1)
        {
            throw new SDGException('sdgDataProviderNative:LoadSDG: Invalid number of SDG results for name: ' + SDGTag + '. retrieved: ' + sdgs.size());
        }
        else
        {
            //Now we can load this:
            SDG__c e;
            e = sdgs[0];
            
            system.debug('sdgDataProviderNative:LoadSDG:Validity: ' + e.is_valid__c);
            if (!e.is_valid__c)
            {
                system.debug('This is an invalid SDG');
                throw new SDGException('SDG: ' + SDGTag + ' is marked as invalid');
            }
            
            CoreSDG = new SDG(e.sObjectName__c, e.Parent_Field_Name__c,  e.sobjectname__c,  e.Filter__c,  e.Default_Sort__c, e.Id, e.All_Rows__c );
            CoreSDG.internalData.DisableSharing = e.DisableSharing__c;

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(CoreSDG.sObjectName);
            if (targetType==null)
            {
                system.debug('sdgDataProviderNative:LoadSDG: invalid sObjectName');
                throw new SDGException('sdgDataProviderNative: Invalid sObjectName provided - are you missing a namespace?');
            }
            Id CoreSDGId = CoreSDG.InternalData.sUniqueKey;

            List<SDG_Field__c> fields = e.sdgfields__r;
            if (fields!=null)
                CoreSDG.SDGFields = GetSDGFields(fields, targetType);
          
            List<SDG_Action__c> actions = e.sdg_actions__r;
            if (actions!=null)
                CoreSDG.SDGActions = GetSDGActions(actions, e.sObjectName__c);
        }
        return coreSDG;
    }
    
    private  List<SDGAction> GetSDGActions(List<SDG_Action__c> actions, String sObjectName)
    {
        

        List<SDGAction> results = sdgMapper.MapToSDGActions(sObjectName, actions);
        results.sort();
        return results;
    }
    private  List<SDGField> GetSDGFields(List<sdg_field__c> fields, Schema.SObjectType targetType )
    {
        
        if (fields.size()==0)
        {
            throw new SDGException('sdgDataProviderNative:GetSDGFields: SDG has no fields');
        }
        
        //Now convert to fields - do FLS checks as well
        List<SDGField> results = sdgMapper.MapToSDGFields(targetType, fields, true);
        results.sort();
        return results;
        
    }

    
}