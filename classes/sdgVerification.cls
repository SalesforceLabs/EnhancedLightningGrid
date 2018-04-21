/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgVerification {

    public static Boolean VerifySDGAndFields(List<string> ids)
    {
        List<SDG__c> sdgs = [select id, sObjectName__c, Parent_field_Name__c, is_valid__c from sdg__c where id in :ids];
        Boolean SDGsHasErrors = VerifySDG(sdgs, true);
        List<sdg_field__c> fields = [select id, apiname__c, sdg__c, is_valid_field__c from sdg_field__c where sdg__c in :sdgs];
        Boolean SDGFieldsHasErrors = VerifySDGFields(fields, true);

        Boolean canSave = (!SDGsHasErrors) && !(SDGFieldsHasErrors);
        if(canSave)
        {
            for (SDG__c sdg: sdgs)
            {
                sdg.is_valid__c = true;
            }
            for (SDG_field__c field: fields)
            {
                field.is_valid_field__c = true;
            }

            update sdgs;

            update fields;
        }
        return canSave;
    }

    public static Boolean VerifySDG(List<SDG__c> sdgs, Boolean MarkInvalid)
    {
        Boolean hasErrors = false;
        //1. is the object name valid
        //2. is the parent field name valid and an ID/Reference field

        //Get list of sObjectNames
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        //Get case insensitive map:
        Map<String, String> gdinsensitive = new Map<String, String>();
        for(String sot : gd.keyset()) {
            String lcase = sot;//.toLowerCase();
            gdinsensitive.put(lcase, gd.get(sot).getDescribe().getName());
        }

        List<String> sobjectNames = new List<String>();
        for(SDG__c sdg : sdgs)
        {
            if (sdg.is_valid__c)
            {

                    if (gdinsensitive.containsKey(sdg.sObjectName__c.tolowercase()))
                    {
                        sdg.sObjectName__c = gdinsensitive.get(sdg.sObjectName__c.tolowercase());
                    }
                    else
                    {
                        if (MarkInvalid)
                        {
                            hasErrors = true;
                            sdg.is_valid__c = false;
                        }
                        else
                        {
                            sdg.AddError('Cannot identify sObject: ' + sdg.sObjectName__c);
                        }
                    }

                if (!String.isblank(sdg.parent_field_name__c))
                {
                    //Verify parentfieldname
                    sdgPathParser pp = new sdgPathParser(sdg.parent_field_name__c, gd.get(sdg.sObjectName__c));
                    try
                    {
                        sdg.Parent_Field_Name__c = pp.FixCase();
                        //Now test if it's an ID:
                        sdgPathParser pp2 = new sdgPathParser(sdg.parent_field_name__c, gd.get(sdg.sObjectName__c));
                        Schema.DisplayType dt = pp2.getDescribe().getType();
                        if (!((dt == Schema.DisplayType.REFERENCE) || (dt == schema.DisplayType.ID)) )
                        {
                            if (MarkInvalid)
                            {
                                hasErrors = true;
                                sdg.is_valid__c = false;
                            }
                            else
                            {
                                sdg.addError('Parent field (' + sdg.Parent_Field_Name__c + ') must be a reference or ID field.');
                            }

                        }
                        else
                        {
                            sdg.is_valid__c = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        if (MarkInvalid)
                        {
                            hasErrors = true;
                            sdg.is_valid__c = false;
                        }
                        else
                        {
                            sdg.AddError('Unable to resolve path: ' + sdg.Parent_Field_Name__c);
                        }
                    }

                    }

            }
        }
        return hasErrors;

    }

    public static Boolean VerifySDGFields(List<SDG_Field__c> sdgfields, Boolean MarkInvalid)
    {
        Boolean hasErrors = false;

        //1. is the api field name valid for the SDG__C
        List<String> ids = new List<string>();
        for(SDG_Field__c field: sdgfields)
        {
            ids.add(field.sdg__c);
        }
        Map<ID, sdg__c> mapSDG = new Map<ID, sdg__c>();
        List<sdg__c> sdgs = [select id, sObjectName__c from sdg__c where id in :ids];
        mapSDG.putAll(sdgs);

        for (sdg_field__c field: sdgfields)
        {
            if (field.is_valid_field__c)
            {
                sdg__c sdg = mapSDG.get(field.sdg__c);

                    //Get list of sObjectNames
                    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    if (String.isBlank(field.apiName__c))
                    {
                        if (MarkInvalid)
                        {
                            field.is_valid_field__c = false;
                            hasErrors = true;
                        }
                        else
                        {
                            field.AddError('API Name is mandatory');
                        }
                    }
                    else
                    {
                        //Verify api name
                        sdgPathParser pp = new sdgPathParser(field.apiName__c, gd.get(sdg.sObjectName__c));
                        try
                        {
                            field.apiname__c = pp.FixCase();
                            field.is_valid_field__c = true;
                        }
                        catch (Exception ex)
                        {
                            if (MarkInvalid)
                            {
                                field.is_valid_field__c = false;
                                hasErrors = true;
                            }
                            else
                            {
                                field.AddError('Unable to resolve API Name: ' + field.apiname__c + ' from ' + sdg.sObjectName__c);
                            }
                        }
                    }

            }
        }
        return hasErrors;
    }

}