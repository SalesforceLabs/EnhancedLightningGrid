/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgPropertiesTest {

    static testMethod void TestList()
    {
        test.startTest();
        //Generate SOSL response: doesn't work in deployment
        //Id [] fixedSearchResults= new Id[1];
        //ApexClass classobj = [select id from apexclass where name = 'sdgDataProviderCustomExample' and namespaceprefix = :sdgNamespaceUtility.getNamespace() limit 1];

        //fixedSearchResults[0] = classobj.id;
        //Test.setFixedSearchResults(fixedSearchResults);


        sdgProperties props1 = new sdgProperties();
        VisualEditor.DynamicPickListRows items1 = props1.getValues();
        integer i = database.countquery ('SELECT count() FROM SDGDefaults__mdt');
        system.debug('count: ' + i);
        system.assertnotequals(0, items1.size(),  'sdgPropertiesTest:TestList Should be at least some items in SDGDefaults');
        //we can't know how many items there are though
        Boolean hasMeta = false;
        Boolean hasCustom = false;
        Boolean hasApex = false;
        for (VisualEditor.DataRow item: items1.getDataRows())
        {
            if (item.getValue()!=null)
            {
                if (String.valueOf((item.getvalue())).startswithignorecase(sdgDataProviderType.Metadata.name()))
                    hasMeta = true;
                if (String.valueOf((item.getvalue())).startswithignorecase(sdgDataProviderType.CustomObject.name()))
                    hasCustom = true;
                if (String.valueOf((item.getvalue())).startswithignorecase(sdgDataProviderType.Apex.name()))
                    hasApex = true;
            }
        }
        system.assertEquals(true, hasMeta, 'sdgPropertiesTest:TestList: Expected a metadata data provider (part of package)');
        system.assertEquals(false, hasCustom, 'sdgPropertiesTest:TestList: Expected no custom data providers');
        system.assertEquals(false, hasApex, 'sdgPropertiesTest:TestList: Expected no apex data provider - so SOSL results set');

        //now add one
        sdgtestdata.GenerateTestSDG();
        //And try again
        sdgProperties props2 = new sdgProperties();
        VisualEditor.DynamicPickListRows items2 = props2.getValues();
        system.assertequals(items1.size()+1, items2.size(), 'sdgPropertiesTest:TestList: Should be 1 more item');

        //now get default:
        VisualEditor.DataRow defaultitem =  props2.getDefaultValue();
        system.assertEquals(sdgProperties.DefaultLabel, defaultitem.getlabel(),'sdgPropertiesTest:TestList: Expected Relationship editor item as default');
        test.stopTest();
    }
}