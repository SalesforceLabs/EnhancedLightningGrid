/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public with sharing class sdgControllerTest {
    /*
    static testMethod void GetSDGTest()
    {
        //Generate test data
        String testid = sdgTestData.GenerateTestSampleData();

        //Prep test catching values:
        Boolean errorThrown=false;
        String errorMsg = '';
        Test.startTest();

        //Test all params missing:
        try
        {
            SDG e = sdgLoaderFactory.LoadSDG('', '', '', '');

        }
        catch (SDGException ex)
        {
            errorThrown = true;
            errorMsg = ex.getMessage();
        }
        system.assertEquals(true, errorThrown, 'Expected an SDGException with no parameters');

        try
        {
            //sdgController SDGObj = new sdgController();
            SDG e = sdgLoaderFactory.LoadSDG(testid, 'Opportunities', '','');

        }
        catch (SDGException ex)
        {
            errorThrown = true;
            errorMsg = ex.getMessage();
        }
        system.assertEquals(true, errorThrown, 'Expected an SDGException with no fieldset');

        Test.stopTest();
    }



    static testMethod void TestCustomObjInitialLoad()
    {
        //Generate test data: an account and an opportunity:
        String testdata=sdgTestData.GenerateTestSampleData();

        STring sdgid = sdgTestData.GenerateTestSDG();
        //do not generate any fields to get an error

        Test.startTest();

        String results = sdgController.GetSDGInitialLoad(testdata, '', '', sdgTestData.TestSDGName);
        //json payload so parse
        SDGInitialLoad initial = (SDGInitialLoad)JSON.deserialize(results, SDGInitialLoad.class);
        system.assertEquals(true, initial.isError,'Expected error for SDG with no fields');
        Test.stopTest();
    }

    static testMethod void TestInvalidCustomObject()
    {
        //Generate test data: an account and an opportunity:
        String testdata=sdgTestData.GenerateTestSampleData();

        STring erlid = sdgTestData.GenerateTestSDG();
        //create invalid row:
        SDG_Field__c efield = new SDG_Field__c();
        efield.apiname__c='notavalidname';
        efield.FieldOrder__c=1;
        efield.sdg__c= erlid;
        efield.is_valid_field__c=true;

        //Prep test catching values:
        Boolean errorThrown=false;
        String errorMsg = '';
        Test.startTest();

        try
        {
            insert efield;

        }
        catch (DMLException ex)
        {
            errorThrown = true;
        }

        Test.stopTest();
        system.assertEquals(true, errorThrown, 'Expected invalid field to throw exception as invalid');

    }

    static testMethod void TestSDGInitialLoad()
    {
        //Generate test data: an account and an opportunity:
        String testdata=sdgTestData.GenerateTestSAmpleDAta();

        STring erlid = sdgTestData.GenerateTestSDG();
        sdgTestData.GenerateTestSDGFieldString(erlid);
        sdgTestData.GenerateTestSDGFieldDate(erlid);
        sdgTestData.GenerateTestSDGFieldBoolean(erlid);
        sdgTestData.GenerateTestSDGFieldPicklist(erlid);

        //Prep test catching values:
        Boolean errorThrown=false;
        String errorMsg = '';
        Test.startTest();

        //Test Happy Path
        String results = sdgController.GetSDGInitialLoad(testdata, sdgTestData.TestSDGName, '', '');
        //json payload so parse
        SDGInitialLoad initial = (SDGInitialLoad)JSON.deserialize(results, SDGInitialLoad.class);
        system.assertEquals(2, initial.results.filteredrowcount,'Expected rowcount=2 from load');
        system.assertEquals(2, initial.results.data.size(),'Expected data size=1 from load');
        system.assertEquals(false, initial.isError,'No error expected: initial');

        //Test UnHappy Path
        errorThrown=false;
        errorMsg = '';

        String results2 = sdgController.GetSDGInitialLoad(testdata, '', '', '');
        SDGInitialLoad initial2 = (SDGInitialLoad)JSON.deserialize(results2, SDGInitialLoad.class);
        system.assertEquals(true, initial2.isError, 'Expected handled error loading invalid Parent ID');
        system.assertEquals(false, initial.isError,'No error expected: initial2 ');
        //Test Unhappy Path

        errorThrown=false;
        errorMsg = '';
        String results3 = sdgController.GetSDGInitialLoad(testdata, '', '', 'invalid value');
        SDGInitialLoad initial3  = (SDGInitialLoad)JSON.deserialize(results3, SDGInitialLoad.class);
        system.assertEquals(true, initial3.isError, 'Expected handled error loading invalid SDG Tag');
        system.assertEquals(false, initial.isError,'No error expected: initial3 ');

        Test.stopTest();
    }

    static SDGResult GetResult(SDGRequest req)
    {
        String results = sdgController.getSDGResult(JSON.serialize(req));
        SDGResult result = (SDGResult)JSON.deserialize(results, SDGResult.class);
        return result;

    }

    static testMethod void TestSort()
    {
        //Generate test data:
        String testdata=sdgTestData.GenerateTestSampleData();

        STring erlid = sdgTestData.GenerateTestSDG();
        String stringfield = sdgTestData.GenerateTestSDGFieldString(erlid);
        String datefield = sdgTestData.GenerateTestSDGFieldDate(erlid);
        String booleanfield = sdgTestData.GenerateTestSDGFieldBoolean(erlid);
        String picklistfield = sdgTestData.GenerateTestSDGFieldPicklist(erlid);
        sdgTestData.GenerateTestSDGFieldTraverseString(erlid);

        Test.startTest();

        //Generate a request:
        SDGRequest req = new SDGRequest();
        req.SDGTag = sdgTestData.TestSDGName;
        req.ParentRecordID = testdata;
        req.pageid=1;
        req.pagesize=5;
        req.sortOrder='A';
        req.sortColumn=stringfield;

        //Now invoke normal list:
        SDGResult result = getresult(req);
        //Test this is sorted?
        system.assertEquals(2, result.filteredrowcount, 'expected two rows in sort results');
        SDG_field__c o = (SDG_field__c)result.data[0];
        system.assertEquals('Name', o.sortablegrid__APIName__c, 'Expected');
        system.assertEquals(false, result.isError,'Should not get error with valid sort value');

        //Test descending sort
        req.sortOrder='D';
        SDGResult result2 = getresult(req);

        //Test this is sorted?
        system.assertEquals(2, result.filteredrowcount, 'expected two rows in sort results');
        SDG_field__c o2 = (SDG_field__c)result.data[0];
        system.assertNotEquals('sortablegrid__APIName__c', o2.sortablegrid__APIName__c, 'Expected changed order');
        system.assertEquals(false, result.isError,'Should not get error with valid sort value');


        //test invalid sort
        req.sortColumn='Account.Name';
        SDGResult result3 = getresult(req);
        //should have an error:
        system.assertEquals(true, result3.isError,'Should get error with invalid sort value');

    }

    static testMethod void TestInvalidSDG()
    {
        //Generate test data: an account and an opportunity:
        String testdatarecordid= sdgTestData.GenerateTestSampleData();

        STring erlid = sdgTestData.GenerateTestSDG();
        String stringfield = sdgTestData.GenerateTestSDGFieldString(erlid);
        String datefield = sdgTestData.GenerateTestSDGFieldDate(erlid);
        String booleanfield = sdgTestData.GenerateTestSDGFieldBoolean(erlid);
        String picklistfield = sdgTestData.GenerateTestSDGFieldPicklist(erlid);

        Test.startTest();

        //Generate a request:
        SDGRequest req = new SDGRequest();
        req.SDGTag = sdgTestData.TestSDGName;
        req.ParentRecordID = testdatarecordid;
        req.pageid=1;
        req.pagesize=5;

        system.debug('request: ' + JSON.serialize(req));
        //Now invoke normal list:
        SDGResult result = getresult(req);
        system.debug('result: ' + JSON.serialize(result));
        system.assertEquals(false, result.isError,'TestInvalidSDG: No error expected with valid SDG');
        system.assertEquals(2, result.filteredrowcount,'TestInvalidSDG: Expected 2 sdgfields as this is a valid SDG');

        //Update SDG:
        Sdg__c sdg = [select id, is_valid__c from sdg__c where id = :erlid limit 1];
        sdg.is_valid__c = false;
        update sdg;
        sdg = [select is_valid__c from sdg__c where id = :erlid limit 1];

        system.debug('set ' + sdg.id + ' to ' + sdg.is_valid__c + ' - should fail now');
        system.debug(JSON.serialize(sdg));
        SDGResult result2 = getResult(req);

        system.assertNotEquals('', result2.ErrorMessage,'Expected error message with is_valid=false');

        system.assertEquals(null, result2.filteredrowcount,'Expected rowcount=0 as this is now invalid sdg');
        system.assertEquals(true, result2.isError,'Expected error with is_valid=false');

        Test.stopTest();
    }
    */
}