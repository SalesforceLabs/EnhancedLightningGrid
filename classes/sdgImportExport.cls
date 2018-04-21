/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgImportExport {
    static integer CURRENTVERSION = 1;
    @AuraEnabled
    public static String ExportSDG(String Id)
    {
        sdgExportFormat pak = new sdgExportFormat();
        pak.version = CURRENTVERSION;
        sdg__c sdg = [select name, sdg_tag__c, default_sort__c, filter__c, is_valid__c, Parent_Field_Name__c,  sObjectName__c, All_Rows__c, DisableSharing__c, (select name, APIName__c, Field_Style__c, FieldOrder__c, Hide_Filter__c, is_valid_field__c, Override_Label__c, sdg__c from SDGFields__r),  (select name, Action_Order__c, Action_Type__c, Event__c, Event_Payload__c, Requires_Createable__c, Requires_Deletable__c, Requires_Editable__c, SDG__c, Icon__c from SDG_Actions__r)  from sdg__c where id = :Id limit 1];
        sdg.Id = null;
        for(sdg_field__c field : sdg.SDGFields__r)
        {
            field.id = null;
            field.sdg__c = null;
        }
        for(sdg_action__c action : sdg.SDG_Actions__r)
        {
            action.id = null;
            action.sdg__c = null;
        }
        pak.sdg = sdg;
        String payload = JSON.serialize(pak);
        return payload;
    }
    @AuraEnabled
    public static String ImportSDG(String payload)
    {

        String Id;
        sdgExportFormat pak;
        try
        {
            pak = (sdgExportFormat)JSON.deserializeStrict(payload, sdgExportFormat.class);
        }
        catch (Exception ex)
        {
            throw new AuraHandledException('Unable to parse payload.  Please check you copied correctly.');
        }

        if (pak.version == CURRENTVERSION)
        {
            try
            {
                sdg__c sdg = pak.sdg;
                insert sdg;
                for(sdg_action__c action : sdg.SDG_Actions__r)
                {
                    action.sdg__c = sdg.id;
                }
                for(sdg_field__c field : sdg.SDGFields__r)
                {

                    field.sdg__c = sdg.id;
                }
                insert sdg.SDG_Actions__r;
                insert sdg.SDGFields__r;
                ID = sdg.Id;
            }
            catch (Exception ex)
            {
                throw new AuraHandledException('Unable to insert payload: ' + ex.getMessage());
            }
        }
        else
        {
            throw new AuraHandledException('Invalid version provided - you cannot import this version into this org.');
        }
        return ID;
    }
    public static SDG__c GetSDG(String payload)
    {

        String Id;
        sdgExportFormat pak;
        try
        {
            pak = (sdgExportFormat)JSON.deserializeStrict(payload, sdgExportFormat.class);
        }
        catch (Exception ex)
        {
            system.debug(ex.getMessage());
            throw new sdgException('sdgImportExport:GetSDG: Unable to parse payload.  Please check you copied correctly.');
        }
        SDG__c sdg;

            try
            {
                sdg = pak.sdg;

            }
            catch (Exception ex)
            {
                throw new AuraHandledException('Unable to insert payload: ' + ex.getMessage());
            }

        return sdg;
    }
}