/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgSecurity {
    global  class sdgInvalidPermissionsException extends sdgException {}
    
    global static Boolean CanQuery(String Context, String sObjectType, String commaDelimitedFields, String nonNamespaceFields, String namespace, Boolean ThrowEx)
    {
        system.debug(Context + ':sdgSecurity:CanQuery for : ' + namespace + sObjectType + ' ' + commaDelimitedFields);
        SObjectType schemaType = Schema.getGlobalDescribe().get(namespace + sObjectType);
        
        Map<String, SObjectField> rawfields = schemaType.getDescribe().fields.getMap();
        
        List<String> fields = new List<String>();
        List<String> allFields = new List<String>();
        
        //Add all the fields
        //adding commadelimited fields to allfields
        for (string loopfield: commaDelimitedFields.split(','))
        {
            if (loopfield.trim().length()>0)
                allfields.add(namespace.trim() + loopfield.trim());
        }
        //adding NonNamespacefields to allfields
        for (string loopfield: NonNamespacefields.split(','))
        {
            if (loopfield.trim().length()>0)
                allfields.add(loopfield.trim());
        }
        
        for (String field : allfields)
            if (rawfields.get( field)==null)
        {
            system.debug('sdgSecurity:CanQuery: Cannot get reference to field: ' + field + ' on object: ' + namespace + sObjectType );
            if (throwex)
                throw new sdgInvalidPermissionsException(Context + ':sdgSecurity:CanQuery: Cannot get reference to field: ' + field + ' on object: ' + namespace + sObjectType );
            return false;
        }
        else
        {
            if (!rawfields.get(field).getDescribe().isAccessible())
            {
                system.debug ('sdgSecurity:CanQuery: User cannot access field: ' + field + ' on object: ' + sObjectType);
                if (throwex)
                    throw new sdgInvalidPermissionsException(Context + ':sdgSecurity:CanQuery: Cannot get access field: ' + field + ' on object: ' + namespace + sObjectType );
                return false;
            }
        }
        return true;
    }
    
    public static List<sdg_action__c> PermittedActions(String sObjectName, List<sdg_action__c> AllActions)
    {
        //Can user edit:
        Boolean bUserCanEdit = false;
        Boolean bUserCanCreate = false;
        Boolean bUserCanDelete = false;
        List<sdg_action__c> permittedActions = new List<sdg_action__c>();
        
        if (String.isBlank( sObjectName))
        {
            system.debug('sdgSecurity:PermittedActions: missing sObjectName');
        }
        else
        {
            
            system.debug(UserInfo.getUserName());
            system.debug('Looking at: ' + sObjectName);
            system.debug(Schema.sObjectType.Opportunity.isDeletable());
			Schema.DescribeSobjectResult result2 = schema.SObjectType.Opportunity;
            
            String[] types = new String[]{sObjectName};
                try
            {
                Schema.DescribeSobjectResult describeResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
				
                bUserCanCreate = describeResult.isCreateable();
     			bUserCanDelete = describeResult.isDeletable();
                bUserCanEdit = describeResult.isUpdateable();
                //Issue when using describesObjects: so have to use a global describe: https://success.salesforce.com/issues_view?id=a1p3A000000mCJlQAM
                /*Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                system.debug(results.size());
                if (results.size()==1)
                {
                    Schema.DescribeSobjectResult result = results[0];
                    system.debug('result.label:');
                    system.debug(result.getLabel());
                    system.debug(result.deletable);
                    system.debug ('Existing value:');
                    system.debug (bUserCanCreate);
                    system.debug('Checking Createable');
                    bUserCanCreate = result.isCreateable()==true;
                    system.debug('checked');
                    system.debug (bUserCanCreate);
                    bUserCanDelete = result.isDeletable() == true;
                    bUserCanEdit = result.isUpdateable() == true;
                    
                }*/
            }
            catch (exception ex)
            {
                system.debug('sdgSecurity:PermittedActions: invalid sObjectName: ' + ex.getMessage());
                throw new SDGException('sdgSecurity:PermittedActions: invalid sObjectName' + ex.getMessage());
            }
            
            system.debug(bUserCanCreate);
            system.debug(bUserCanDelete);
            system.debug(bUserCanEdit);
            
            
            for (sdg_action__c a : AllActions)
            {
                Boolean UserCanUseAction = true;
                if (a.Requires_Createable__c && !bUserCanCreate)
                {
                    UserCanUseAction = false;
                }
                if (a.Requires_Editable__c && !bUserCanEdit)
                {
                    UserCanUseAction = false;
                }
                if (a.Requires_Deletable__c && !bUserCanDelete)
                {
                    UserCanUseAction = false;
                }
                if (UserCanUseAction)
                {
                    permittedActions.add(a);
                }
            }
        }
        return permittedActions;
    }
}