/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@isTest
public class sdgDataProviderFactoryTest {

    static testMethod void checkDeprecatedDataProviders()
    {
        Boolean isError = false;
        try{
            SDG s = new sdg();
            CustomDataProviderExample cdpe = new CustomDataProviderExample();
            cdpe.LoadSDG(s);
            sdgRelationshipDataProvider rdp = new sdgRelationshipDataProvider();
            rdp.LoadSDG(s);
            sdgMetadataDataProvider mdp = new sdgMetadataDataProvider();
            mdp.LoadSDG(s);
 
        }
        catch(Exception ex)
        {
            isError = true;
            system.assertEquals(true, isError, 'sdgDataProviderFactoryTest:checkDeprecatedDataProviders');
        }
    }
    static testMethod void getClassNameTestInvalid()
    {
        Test.startTest();
        Boolean isGoodError = false;
        Boolean isBadError = false;
        try
        {
        Boolean result3 = sdgDataProviderFactory.isNameValid('something else entirely');
        }
        catch (sdgDataProviderFactory.sdgInvalidConfigurationNameException sdgex)
        {
            isGoodError = true;
        }
        catch (Exception ex)
        {
            isBadError = true;
        }
        Test.stopTest();
        system.assertEquals(true,isGoodError, 'sdgDataProviderTest:getClassNameTestInvalid: expected handled error');
        system.assertEquals(false,isBadError, 'sdgDataProviderTest:getClassNameTestInvalid: Did not expect unhandled error');

    }
    static testMethod void getClassNameTest()
    {
        Test.startTest();
        Boolean result = sdgDataProviderFactory.isNameValid('apex:testing');
        Boolean result2 = sdgDataProviderFactory.isNameValid('aPEx:sdgDataProviderApexExample');

        Boolean result4 = sdgDataProviderFactory.isNameValid('Relationship:bob');
        Boolean result5 = sdgDataProviderFactory.isNameValid('Metadata:whatever');

        Test.stopTest();
        system.assertEquals(true, result, 'sdgDataProviderFactoryTest:isNameValid Expected to be identified as false: invalid apex name');
        system.assertEquals(true, result2, 'sdgDataProviderFactoryTest:isNameValid Expected to be identified as apex class');
        system.assertEquals(true, result4, 'sdgDataProviderFactoryTest:isNameValid Expected to be identified as relationship');
        system.assertEquals(true, result5, 'sdgDataProviderFactoryTest:isNameValid Expected to be identified as metadata provider');

    }

    static testMethod void getClassTest()
    {
        Test.startTest();
        sdgIDataProvider result =  sdgDataProviderFactory.getClass('metadata:abc');
        system.debug('result1 OK');
        sdgIDataProvider result2 = sdgDataProviderFactory.getClass('aPEx:sdgDataProviderApexExample');
        system.debug('result2 OK');
        sdgIDataProvider result3 = sdgDataProviderFactory.getClass('relationship:Accounts');
        system.debug('result3 OK');
        sdgIDataProvider result4 = sdgDataProviderFactory.getClass('CustomObject:Account');
        system.debug('result4 OK');
        Test.stopTest();
        system.assertEquals(true, result instanceof sdgDataProviderMetadata, 'sdgDataProviderFactoryTest:getClass Expected to get sdgDataProviderMetadata  name');
        system.assertEquals(false, result instanceof SDGDataProviderRelationship, 'sdgDataProviderFactoryTest:getClass Expected to not get SDGDataProviderRelationship');
        system.assertEquals(true, result2 instanceof SDGDataProviderApexExample, 'sdgDataProviderFactoryTest:getClass Expected to get SDGDataProviderApexExample apex name');
        system.assertEquals(true, result3 instanceof SDGDataProviderRelationship, 'sdgDataProviderFactoryTest:getClass Expected to be identified as SDGDataProviderRelationship');
        system.assertEquals(true, result4 instanceof SDGDataProviderNative, 'sdgDataProviderFactoryTest:getClass Expected to be identified as SDGDataProviderNative');
    }

    static testMethod void getClassInvalidTest()
    {
        Test.startTest();
        Boolean hasError = false;
        try
        {
            sdgIDataProvider result = sdgDataProviderFactory.getClass('apex:testing');
        }
        catch (exception ex)
        {
            hasError = true;
        }
        Test.stopTest();
        system.assertEquals(true, hasError , 'sdgDataProviderFactoryTest:getClassInvalid Expected error as invalid apex class name');

    }
    static testMethod void getClassInvalid2Test()
    {
        Test.startTest();
        Boolean hasError = false;
        sdgIDataProvider result;
        try
        {
             result = sdgDataProviderFactory.getClass('CustomObject:zip');
        }
        catch (exception ex)
        {
            hasError = true;
        }
        Test.stopTest();
        system.assertEquals(false, hasError , 'sdgDataProviderFactoryTest:getClassInvalid2 Expected no error despite invalid sobject name');
        system.assertEquals(true, result instanceof SDGDataProviderNative, 'sdgDataProviderFactoryTest:getClass Expected to be identified as SDGDataProviderNative even though invalid sobjectname');

    }
}