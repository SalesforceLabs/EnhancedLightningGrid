/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgFieldTest {

    static testMethod void GetCreate()
    {
        test.startTest();
        SDGField f = new SDGField();
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest: Expected a SDGField to be created.');

    }
    static testmethod void GetCreate2()
    {
          test.startTest();
        List<AuraSelectOption> opts = new List<AuraSelectOption>();
        SDGField f = new SDGField('1', 'a label', 'Name', 'STRING', '', true, false, opts);
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest:GetCreate2: Expected a rich SDGField to be created.');
        system.assertEquals(true, f.canSort, 'SDGFieldTest:GetCreate2: Expected field to be saved');
   
   }
       static testmethod void GetCreate3()
    {
          test.startTest();
        List<AuraSelectOption> opts = new List<AuraSelectOption>();
        SDGField f = new SDGField('1', 'a label', 'Name', 'STRING', '', true, false, false, opts, 1);
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest:GetCreate3: Expected a rich SDGField to be created. Not HTML formatted');
        system.assertEquals(true, f.canSort, 'SDGFieldTest:GetCreate3: Expected field to be saved');
   
   }
    static testmethod void GetCreateFullDeprecated()
    {
        Boolean isError = false;
        try
        {

            List<AuraSelectOption> opts = new List<AuraSelectOption>();
            SDGField f = new SDGField('1', 'a label', 'STRING', '',  '', false, opts);

        }
        catch(sdgDeprecatedException ex)
        {
            isError = true;
        }
        system.assertEquals(true, isError, 'sdgFieldTest:GetCreateFullDeprecated: Expected sdgDeprecatedException');

    }
    static testMethod void GetCreateFull()
    {
        test.startTest();
        List<AuraSelectOption> opts = new List<AuraSelectOption>();
        SDGField f = new SDGField('1', 'a label', 'STRING', '', '', true, false, opts, 1);
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest:GetCreateFull: Expected a rich SDGField to be created.');
        system.assertEquals(true, f.canSort, 'SDGFieldTest:GetCreateFull: Expected field to be saved');
    }
}