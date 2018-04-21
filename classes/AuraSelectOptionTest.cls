/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class AuraSelectOptionTest {

    static testmethod void TestSort()
    {
        List<AuraSelectOption> items = new List<AuraSelectOption>();
        AuraSelectOption a = new AuraSelectOption('a', 'a');
        AuraSelectOption b = new AuraSelectOption('b', 'b');
        AuraSelectOption c = new AuraSelectOption('c', 'c');
        AuraSelectOption d = new AuraSelectOption('d', 'd');
        items.add(b);
        items.add(a);
        items.add(d);
        items.add(c);
        system.assertEquals('b', items[0].label, 'Expected auraselectoption to have b first');
        system.assertEquals('c', items[3].label, 'Expected auraselectoption to have c last');
        items.sort();
        system.assertEquals('a', items[0].label, 'Expected auraselectoption sort to put a first');
        system.assertEquals('d', items[3].label, 'Expected auraselectoption to have d last');
    }
    static testmethod void DefaultSelected()
    {
        AuraSelectOption a = new AuraSelectOption('a', 'a', true);
        AuraSelectOption b = new AuraSelectOption('b', 'b', false);
        AuraSelectOption c = new AuraSelectOption('c', 'c');
        system.assertEquals(true, a.selected, 'Expected auraselectoption to have selected = true');
        system.assertEquals(false, b.selected, 'Expected auraselectoption to have selected = false');
        system.assertEquals(false, c.selected, 'Expected auraselectoption to default selected to false');


    }
}