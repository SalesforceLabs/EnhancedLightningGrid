/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgDesigner {
    @AuraEnabled
    public static string GetNamespace()
    {
        return sdgNamespaceUtility.GetNamespace();
    }
    
    @AuraEnabled
    public static Integer GetNewFieldOrder( String SDGRecordId)
    {
        Integer retvalue = 1;
        try
        {
            
            sdgSecurity.CanQuery('SDGDesigner:GetNewFieldOrder', 'SDG_Field__c', 'FieldOrder__c', '', sdgNamespaceUtility.GetNamespace(),true);
            
            AggregateResult[] groupedResults = [SELECT Max(FieldOrder__c) current FROM SDG_Field__c where sdg__c = : SDGRecordId];
            Object maxValueObj = groupedResults[0].get('current');
            Integer maxValueInt = Integer.valueOf(maxValueObj);
            retvalue =  maxValueInt + 1;
            
        }
        catch (Exception ex)
        {
            //Ignore - Just return a value regardless
        }
        return retvalue;
    }
    
    @AuraEnabled
    public static List<AuraFieldSelectOption> GetSObjectFields(String sObjectType, String SDGRecordId)
    {
        List<AuraFieldSelectOption> objects = new List<AuraFieldSelectOption>();
        objects.add(new AuraFieldSelectOption('','', ''));
        
        try
        {
            if (String.isNotBlank(SDGRecordId) && STring.isBlank(sObjectType))
            {
                Id recordId = (Id)SDGRecordId;
                SDG__c sdg = [select id, sObjectName__c from sdg__c where id = :recordId limit 1];
                sObjectType =sdg.sObjectName__c;
            }
            
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{sObjectType});
            Map<String, Schema.SObjectField> sofs = descResult[0].fields.getMap();
            
            for (Schema.SObjectField sof : sofs.values())
            {
                Schema.DescribeFieldResult dfr =  sof.getDescribe();
                List<Schema.sObjectType> refTos = dfr.getReferenceTo();
                for (schema.SObjectType ref : refTos)
                {
                    if (sof.getDescribe().getRelationshipName()!=null)
                    {
                        objects.add( new AuraFieldSelectOption( sof.getDescribe().getRelationshipName(), ref.getDescribe().getName(), dfr.getLabel() + '-->' + ref.getDescribe().getLabel()  ));
                        
                    }
                }
                objects.add(new AuraFieldSelectOption(dfr.getname(), '', dfr.getlabel()));
            }
            objects.sort();
            
        }
        catch (Exception ex)
        {
            //probably an apex handler - so ignore for now
        }
        return objects;
    }
    
    
}