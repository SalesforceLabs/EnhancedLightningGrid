/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@istest
public class sdgTestOldDataProviders {
    private static testmethod void TestMeta()
    {
        Boolean isError = false;
        try
        {


            sdgMetadataDataProvider.getData(null,null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestMeta:GetData: Expected sdgDeprecatedException');

        isError = false;

        try
        {

            sdgMetadataDataProvider mdp = new sdgMetadataDataProvider();
            mdp.LoadSDG(null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestMeta:LoadSDG: Expected sdgDeprecatedException');
    }


    private static testmethod void TestRelationship()
    {
        Boolean isError = false;
        try
        {


            sdgRelationshipDataProvider.getData(null,null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestRelationship:GetData: Expected sdgDeprecatedException');

        isError = false;

        try
        {

            sdgRelationshipDataProvider dp = new sdgRelationshipDataProvider();
            dp.LoadSDG(null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestRelationship:LoadSDG: Expected sdgDeprecatedException');

        isError = false;

        try
        {

            sdgRelationshipDataProvider dp = new sdgRelationshipDataProvider();
            dp.LoadSDG(null, null, null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestRelationship:LoadSDG 3Params: Expected sdgDeprecatedException');

    }
    private static testmethod void TestCustom()
    {
        Boolean isError = false;
        try
        {


            customDataPRoviderExample.getData(null,null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestCustom:GetData: Expected sdgDeprecatedException');

        isError = false;

        try
        {

            customDataPRoviderExample dp = new customDataPRoviderExample();
            dp.LoadSDG(null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestCustom:LoadSDG: Expected sdgDeprecatedException');
    }


    private static testmethod void TestNative()
    {
        Boolean isError = false;
        try
        {


            sdgNativeDataProvider.getData(null,null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestNative:GetData: Expected sdgDeprecatedException');

        isError = false;

        try
        {

            sdgNativeDataProvider dp = new sdgNativeDataProvider();
            dp.LoadSDG(null);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgTestOldDataProviders:TestNative:LoadSDG: Expected sdgDeprecatedException');
    }
}