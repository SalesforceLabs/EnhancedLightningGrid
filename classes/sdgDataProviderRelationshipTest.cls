/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgDataProviderRelationshipTest {

    private static testmethod void isSelectableTest()
    {
        system.assertequals(false, sdgDataProviderRelationship.isUserSelectable(), 'sdgDataProviderRelationshipTest:isUserSelectable Should not be userSelectable');

    }
    static testMethod void loadSDG()
    {
        //create an sdg
        String sdgid = sdgTestData.GenerateTestSampleData();

        test.startTest();
        SDG s = sdgDataProviderFactory.LoadSDG(sdgDataProviderType.Relationship.name(),sdgid,sdgNamespaceUtility.GetNamespace() + 'SDGFields__r', '');

        //Should be only the ID field - as the fieldset won't exist
        system.assertEquals(1, s.SDGFields.size(), 'Fields on relationship data provider (default fieldset)');
        system.assertEquals(null, s.SDGActions, 'No actions on relationship data provider');

        test.stopTest();

    }
    static testMethod void getDataFieldSet()
    {
        Id sdgid = sdgTestData.GenerateTestSampleData();

        test.startTest();

        SDGREquest req = new SDGRequest();
        req.SDGTag = sdgDataProviderType.Relationship + ':';
        req.FieldSetName = sdgNamespaceUtility.GetNamespace() +'default';
        req.ParentRecordID = sdgid;
        req.RelationshipName = sdgNamespaceUtility.GetNamespace() + 'SDGFields__r';
        req.pageid=1;
        req.pagesize=5;
        sdgresult sr = sdgDataProviderFactory.getData(req);

        system.assertEquals(2, sr.FullQueryCount, 'Two rows in test data');


        test.stopTest();

    }
    static testMethod void getDataDefault()
    {
        Id sdgid = sdgTestData.GenerateTestSampleData();

        test.startTest();

        SDGREquest req = new SDGRequest();
        req.SDGTag = sdgDataProviderType.Relationship + ':';
        req.FieldSetName = '';
        req.ParentRecordID = sdgid;
        req.RelationshipName = sdgNamespaceUtility.GetNamespace() + 'SDGFields__r';
        req.pageid=1;
        req.pagesize=5;
        sdgresult sr = sdgDataProviderFactory.getData(req);

        system.assertEquals(2, sr.FullQueryCount, 'Two rows in test data');


        test.stopTest();

    }
}