/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public with sharing class sdgImportExportTest {

    static testMethod void exportValidTest()
    {
        //generate a test SDG:
        String sid = sdgTestDAta.GenerateTestSampleData();
        sdgTestData.GenerateAction(sid);
        Test.startTest();
        String s = sdgImportExport.ExportSDG(sid);
        List<SDG__c> sdgs = [select id from sdg__c where id = :sid];
        delete sdgs;
        integer istart = database.countQuery('select count() from sdg__c');
        try
        {
       		 string s2 = sdgImportExport.ImportSDG(s);
        }
        catch (exception ex)
        {
            system.debug(ex.getMessage() + ' : ' + ex.getCause() + ' : ' + ex.getStackTraceString());
            system.assert(false, ex.getStackTraceString());
        }
        integer ifinish = database.countQuery('select count() from sdg__c');
        Test.stopTest();
        system.assertEquals(0, istart, 'Expected 0 SDG to start');
        system.assertEquals(1, ifinish, 'Expected an SDG to be created');


    }

    static testMethod void importInvalidVersionTest()
    {
        //generate a test SDG, export, change version, and try to import:
        String sid = sdgTestDAta.GenerateTestSampleData();
        sdgTestData.GenerateAction(sid);

        String s = sdgImportExport.ExportSDG(sid);
        sdgExportFormat pak;

        pak = (sdgExportFormat)JSON.deserializeStrict(s, sdgExportFormat.class);
        pak.version = 2;
        s = JSON.serialize(pak);

        List<SDG__c> sdgs = [select id from sdg__c where id = :sid];
        delete sdgs;
        Test.startTest();
        Boolean haserrors = false;
        try
        {
            string s2 = sdgImportExport.ImportSDG(s);
        }
        catch (exception ex)
        {
            haserrors = true;
        }
        Test.stopTest();
        system.assertEquals(true,haserrors, 'Expected exception due to pak version');


    }

    static testMethod void importInvalidFormaTest()
    {
        //generate a test SDG, export, edit and try to import:
        String sid = sdgTestData.GenerateTestSampleData();
        sdgTestData.GenerateAction(sid);

        String s = sdgImportExport.ExportSDG(sid);
        //make it invalid
        s = s.left(s.length() -2);

        List<SDG__c> sdgs = [select id from sdg__c where id = :sid];
        delete sdgs;
        Test.startTest();
        Boolean haserrors = false;
        try
        {
            string s2 = sdgImportExport.ImportSDG(s);
        }
        catch (exception ex)
        {
            haserrors = true;
        }
        Test.stopTest();
        system.assertEquals(true,haserrors, 'Expected exception due to invalid payload version');


    }
}