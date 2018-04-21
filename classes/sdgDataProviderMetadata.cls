/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgDataProviderMetadata implements sdgIDataProvider {
    global static Boolean isUserSelectable()
    {
        return false;
    }

    global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {

        SDGResult result =  sdgQueryEngine.getSDGResultRaw(CoreSDG, request);
        return result;
    }


    global SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        SDG CoreSDG = null;
        try
        {

            SDGDefaults__mdt md = [SELECT Id, Definition__c FROM SDGDefaults__mdt where developername = :SDGTag limit 1];
     
            String definition = md.definition__c.replace('$namespace$', sdgNamespaceUtility.GetNamespace());
     
            SDG__c e =  sdgImportExport.getSDG(definition);

            CoreSDG = sdgMapper.Convert(e, e.sdgfields__r, sdgSecurity.PermittedActions(e.sObjectName__c, e.sdg_actions__r), false);

            //now put the fields and action ids on - as they won't be in the pak payload
            integer iCounter = 1;
            coresdg.SDGFields.sort();
            coresdg.SDGActions.sort();
            
            for (SDGField field: coresdg.SDGFields)
            {
                field.id = string.valueOf(icounter);
                icounter++;
            }
            for (sdgAction action: coresdg.SDGActions)
            {
                action.id = string.valueOf(icounter);
                icounter++;
            }


            system.debug('sdgDataProviderMetadata:LoadSDG: ' + SDGTag + ' ' + JSON.serialize(CoreSDG) );
        }
        catch (Exception ex)
        {
            throw new sdgException('sdgDataProviderMetadata:LoadSDG: ' + SDGTag + ' : ' + ex.getMessage());
        }
        return coreSDG;
    }


}