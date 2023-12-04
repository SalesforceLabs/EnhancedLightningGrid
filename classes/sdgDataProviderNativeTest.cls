/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@isTest
public class sdgDataProviderNativeTest {

    private static testmethod void isSelectableTest()
    {
        system.assertequals(false, sdgDataProviderNative.isUserSelectable(), 'sdgDataProviderNativeTest:isUserSelectable Should not be userSelectable');

    }

    private static testmethod void testNoFields()
    {
        string testtag = 'a string';
		String sdgID = sdgTestData.GenerateCoreSDG(testtag);
        boolean iserror = false;
        boolean isexpectederror = false;
        try
        {
            sdgDataProviderNative dp = new sdgDataProviderNative();
        	SDG newsdg = dp.LoadSDG(sdgDataProviderType.CustomObject.name() + ':' + testtag,'');
        }
        catch( SDGException sdgex)
        {
            isexpectederror = true;
        }
        catch (exception ex)
        {
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            iserror = true;
        }
        system.assertequals(false, iserror, 'sdgDataProviderNativeTest:testNoFields Should not throw unhandled exception');
        system.assertequals(true, isExpectedError, 'sdgDataProviderNativeTest:testNoFields Should throw with no fields');

    }
}