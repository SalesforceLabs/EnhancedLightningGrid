/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgVerificationTest {

    static testmethod void TestSDGInvalidObjectName()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'asillyname';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'an impossible object name';
        sdg.is_valid__c = true;
        test.startTest();
        Boolean errorThrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        system.assertequals(True, errorThrown, 'Expected SDG error on invalid object name' );
        sdg.is_valid__c = false;
        errorthrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        system.assertequals(False, errorThrown, 'Expected no SDG error as marked invalid' );
        Test.stopTest();
    }
    static testmethod void TestSDGValidObjectName()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'a title';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'account';
        sdg.is_valid__c = true;
        test.startTest();
        Boolean errorThrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        system.assertequals(False, errorThrown, 'Expected no error on object name' );
        //reload item:
        sdg = [select sObjectName__c from sdg__c where id = :sdg.Id limit 1];

        system.assertequals(sdg.sObjectName__c, 'Account', 'Should have changed name from account to Account 1');
        system.assertnotequals(sdg.sObjectName__c, 'account', 'Should have changed name from account to Account 2');

        Test.stopTest();
    }
    static testmethod void VerifySDGForce()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'asillyname';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'an impossible object name';
        sdg.is_valid__c = false;
        insert sdg;
        test.startTest();
        Boolean errorThrown = false;
        List<sdg__c> sdgs = new List<sdg__c>();
        sdgs.add(sdg);
        sdg.is_valid__c = true;  //but not committed;
        system.assertequals(sdg.is_valid__c, true, 'SDG should now be valid before test');
        Boolean result = false;
        try
        {
            result = sdgVerification.VerifySDG(sdgs, true);

        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        system.assertequals(sdg.is_valid__c, false, 'SDG should now be invalid');

    }
    static testmethod void TestSDGParentNameCase()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = true;
        sdg.Parent_Field_Name__c = 'account.id';
        test.startTest();

        Boolean errorThrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        //reload item:
        sdg = [select Parent_Field_Name__c from sdg__c where id = :sdg.Id limit 1];

        system.assertequals(errorThrown, false, 'SDG should not be invalid');
        system.assertNotEquals(sdg.Parent_Field_Name__c, 'account.id', 'Parent field name should have changed 1');
        system.assertEquals(sdg.Parent_Field_Name__c, 'Account.Id', 'Parent field name should have changed 2');
        test.stopTest();

    }

    static testmethod void TestSDGParentNotId()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = true;
        sdg.Parent_Field_Name__c = 'account.Name';
        test.startTest();

        Boolean errorThrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        //reload item:
        //sdg = [select Parent_Field_Name__c from sdg__c where id = :sdg.Id limit 1];

        system.assertequals(errorThrown, true, 'SDG should  be invalid');
        test.stopTest();

    }
    static testmethod void TestSDGParentNotIdMarkInvalid()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = false;
        sdg.Parent_Field_Name__c = 'account.Name';
        test.startTest();
        insert sdg;
        List<sdg__c> sdgs = new List<sdg__c>();
        sdgs.add(sdg);
        Boolean errorThrown = false;
        try
        {

            sdg.is_valid__c = true;
            system.assertequals(sdg.is_valid__c, true, 'Should be valid before test');
            sdgVerification.VerifySDG(sdgs, true);
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        //reload item:
        sdg = [select is_valid__c, Parent_Field_Name__c from sdg__c where id = :sdg.Id limit 1];

        system.assertequals(errorThrown, false, 'Should not throw an error');
        system.assertequals(sdg.is_valid__c, false, 'Should be invalid as name not id');

        test.stopTest();

    }

    static testmethod void TestSDGParentInvalidMarkInvalid()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = false;
        sdg.Parent_Field_Name__c = 'account.name';
        test.startTest();
        insert sdg;
        List<sdg__c> sdgs = new List<sdg__c>();
        sdgs.add(sdg);
        Boolean errorThrown = false;
        try
        {

            sdg.is_valid__c = true;
            sdg.Parent_Field_Name__c = 'account.zoop';

            system.assertequals(sdg.is_valid__c, true, 'Should be valid before test');
            sdgVerification.VerifySDG(sdgs, true);
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        //reload item:
        sdg = [select is_valid__c, Parent_Field_Name__c from sdg__c where id = :sdg.Id limit 1];

        system.assertequals(errorThrown, false, 'Should not throw an error');
        system.assertequals(sdg.is_valid__c, false, 'Should be invalid as name invalid');

        test.stopTest();

    }

    static testmethod void TestSDGParentInvalidName()
    {
        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = true;
        sdg.Parent_Field_Name__c = 'account.Twinkles';
        test.startTest();

        Boolean errorThrown = false;
        try
        {
            insert sdg;
        }
        catch (Exception ex)
        {
            errorthrown = true;
        }
        system.assertequals(errorThrown, true, 'SDG should be invalid with an invalid parent name');
        test.stopTest();

    }

    static testmethod void VerifySDGAndFieldsTest()
    {
        String s = sdgTestData.GenerateTestSampleData();
        sdgTestData.GenerateTestSDGFieldString(s);

        List<String> ids = new List<String>();
        ids.add(s);

        test.startTest();

        Boolean result = sdgVerification.VerifySDGAndFields(ids);
        system.assertEquals(true,result, 'Should be able to save this SDG');
        //Load item again
        sdg__c sdg = [select id, is_valid__c, sObjectName__c from sdg__c where id = :s];
        system.assertEquals(true,sdg.is_valid__c, 'SDG should now be valid');

        Test.stopTest();

    }

    static testmethod void TestSDGFieldPath()
    {
        String sdgid = sdgTestDAta.GenerateTestSDG();

        SDG_Field__c efield = new SDG_Field__c();
        efield.apiname__c='amounts';
        efield.FieldOrder__c=5;
        efield.is_valid_field__c = true;
        efield.sdg__c= SDGid;
        Test.startTest();
        Boolean errorThrown =false;
        try
        {
            insert efield;
        }
        catch (DMLException ex)
        {
            errorThrown = true;
        }

        system.assertEquals( errorThrown, true, 'Expected error for invalid field name');

        errorThrown =false;
        try
        {
            efield.apiname__c = sdgNamespaceUtility.GetNamespace() + 'apiname__c';
            insert efield;
        }
        catch (DMLException ex)
        {
            errorThrown = true;
        }

        system.assertEquals( errorThrown, false, 'Expected no error for valid field name');


    }

    static testmethod void TestSDGFieldPathVerify()
    {
        String sdgid = sdgTestDAta.GenerateTestSDG();

        SDG_Field__c efield = new SDG_Field__c();
        efield.apiname__c=sdgNamespaceUtility.GetNamespace() + 'apiname__c';
        efield.FieldOrder__c=5;
        efield.is_valid_field__c = true;
        efield.sdg__c= SDGid;
        insert efield;
        List<SDG_Field__c> sdgfields = new list<sdg_field__c>();
        sdgfields.add(efield);

        Test.startTest();
        Boolean errorThrown =false;
        try
        {
            efield.apiname__c='amounts';
            Boolean hasErrors = sdgVerification.VerifySDGFields(sdgfields, true);
            system.assertEquals(true, hasErrors, 'Should not be able to save this SDG field');

        }
        catch (DMLException ex)
        {
            errorThrown = true;
        }
        //Load item again
        efield = [select id, is_valid_field__c, apiname__c from sdg_field__c where id = :efield.id limit 1];

        system.assertEquals(true,efield.is_valid_field__c, 'SDG field should now be invalid');

        system.assertEquals( errorThrown, false, 'Expected no error for invalid field name');

        errorThrown =false;
        string emsg = '';
        try
        {
            efield.apiname__c = sdgNamespaceUtility.GetNamespace() + 'apiname__c';
            update efield;
        }
        catch (DMLException ex)
        {
            emsg = ex.getMessage();
            errorThrown = true;
        }

        system.assertEquals( errorThrown, false, 'Expected no error for valid field name: ' + emsg);


    }

}