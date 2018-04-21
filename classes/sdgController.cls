/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class sdgController {


    @AuraEnabled
    public static string GetNamespace()
    {
        return JSON.serialize( sdgNamespaceUtility.GetNamespace());
    }

    @AuraEnabled
    public static String GetSDGInitialLoad(String ParentRecordID, String SDGTag, String RelationshipName, String FieldSetName, integer DefaultPageSize)
    {
        //Create response object
        SDGInitialLoad initial = new SDGInitialLoad();
        // Salesforce bug with Lightning serializer requires re-casting this value
        //https://salesforce.stackexchange.com/questions/108355/limit-expression-must-be-of-type-integer-error-when-using-apex-variable-in-soq/108423#108423
        try {
            DefaultPageSize = Integer.valueOf(DefaultPageSize);
        }
        catch (Exception ex)
        {
            throw new AuraHandledException('Invalid DefaultPageSize provided');
        }
        
        system.debug('sdgController:GetSDGInitialLoad:' + ParentRecordID + ':' + SDGTag + ':' + RelationshipName + ':' + FieldSetName);
        try
        {
            SDG newSDG = SDGDataProviderFactory.LoadSDG(SDGTag, ParentRecordId, RelationshipName, FieldsetName);
            //Create a full request:
            SDGRequest req = new SDGRequest();

            if (!String.isBlank(SDGTag))
            {
            	req = sdgPreferences.GenerateRequestWithFilters(newSDG, ParentRecordID, SDGTag);
            } 
            req.RelationshipName = RelationshipName;
            req.FieldSetName = FieldSetName;
            req.ParentRecordID = ParentRecordID;
            req.SDGTag = SDGTag;
            req.PageSize = DefaultPageSize;

            SDGResult result = sdgDataProviderFactory.getData( req, newSDG);
            //Blank out the internal data to save payload:
            newSDG.InternalData = null;

            //build response object:
            initial.SDGObject = newSDG;
            initial.results = result;
            initial.isError = false;
        }
        
        catch (SDGException ex)
        {
            initial.ErrorMessage = ex.getMessage();
            initial.isError = true;
        }
        catch (Exception standardex)
        {
            initial.ErrorMessage = standardex.getMessage();
            initial.isError = true;
        }
        return JSON.serialize(initial);
    }

    @AuraEnabled
    public static string getSDGResult(String jsonrequest)
    {
        SDGResult results = new SDGResult();

        String resultsstring = '';
        try
        {
            system.debug('sdgController:getSDGResult: getting request');
            SDGRequest request = (SDGRequest)JSON.deserialize(jsonrequest, SDGRequest.class);
            system.debug('sdgController:getSDGResult: getting result');

            results = sdgDataProviderFactory.getData(request);

            results.isError=false;
        }
        catch (Exception ex)
        {
            system.debug('sdgController:getSDGResult: Exception: ' + ex.getMessage() );
            results.ErrorMessage = ex.getMessage();
            results.isError = true;
        }
        return JSON.serialize(results);
    }
}