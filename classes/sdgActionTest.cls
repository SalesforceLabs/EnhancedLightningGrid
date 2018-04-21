/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgActionTest {


    static testMethod void GetCreate()
    {
        test.startTest();
        SDGAction f = new SDGAction();
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGActionTest: Expected a SDGAction to be created.');

    }

 static testMethod void GetCreateFull()
    {
        test.startTest();
        SDGAction f = new SDGAction('1', 'a label', 'an event', 'STRING', '[]', 'iconname', 1);
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest:GetCreateFull: Expected a rich SDGField to be created.');
        system.assertEquals('iconname', f.icon, 'SDGActionTest:GetCreateFull: Expected action to be saved');
    }
     static testMethod void GetCreateNoOrder()
    {
        test.startTest();
        SDGAction f = new SDGAction('2', 'first item', 'an event', 'STRING', '[]', 'iconname',1);
        SDGAction f2 = new SDGAction('1', 'second item', 'an event', 'STRING', '[]', 'iconname');
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFieldTest:GetCreateNoOrder: Order in constructor: Expected a rich SDGField to be created.');
        system.assertNotEquals(null,f2, 'SDGFieldTest:GetCreateNoOrder:  No Order in constructore: Expected a rich SDGField to be created.');
        system.assertEquals('iconname', f.icon, 'SDGActionTest:GetCreateNoOrder: Expected action to be saved');
    }

}