/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public with sharing class sdgDataProviderMetadataTest {

    private static testmethod void isSelectableTest()
    {
        system.assertequals(false, sdgDataProviderMetadata.isUserSelectable(), 'sdgDataProviderMetadataTest:isUserSelectable Should not be userSelectable');

    }
    static testMethod void loadSDG()
    {
        string tag = sdgDataProviderType.Metadata.name() + ':SDG_Designer_Fields';

        test.startTest();
        //not actually interested in whether this works - only the structure
        SDG s = sdgDataProviderFactory.LoadSDG(tag,'','','');
        system.assertNotEquals(null, s, 'sdgMetadataDataProviderTest:loadSDG returned null');

        system.debug(json.serialize(s));
        system.assertNotEquals(0, s.SDGFields.size(), 'sdgMetadataDataProviderTest:loadSDG:Fields on example data provider');
        system.assertNotEquals(0, s.SDGActions.size(), 'sdgMetadataDataProviderTest:loadSDG:Actions on example data provider');
        test.stopTest();

    }
    static testMethod void getData()
    {
        string tag = sdgDataProviderType.Metadata.name() + ':SDG_Designer_Fields';

        test.startTest();

        SDGREquest req = new SDGREquest();
        req.SDGTag = tag;
        req.pageid=1;
        req.pagesize=5;

        sdgresult sr = sdgDataProviderFactory.getData(req);
        system.assertEquals(0, sr.FullQueryCount, 'sdgMetadataDataProviderTest:getData:Fields: No Fields to load');

        req.ParentRecordID = sdgTestData.GenerateTestSampleData();

        sdgresult sr2 = sdgDataProviderFactory.getData(req);
        system.assertNotEquals(0, sr2.FullQueryCount, 'sdgMetadataDataProviderTest:getData:Fields: Fields to load expected');

        test.stopTest();


    }

    
}