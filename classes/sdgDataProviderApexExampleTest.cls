/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@isTest
public class sdgDataProviderApexExampleTest
 {

    static testMethod void loadSDG()
    {
        string tag = sdgDataProviderType.Apex.name() + ':sdgDataProviderApexExample';
        //create an sdg with relevant tag:

        test.startTest();
        //not actually interested in whether this works - only the structure
        SDG s = sdgDataProviderFactory.LoadSDG(tag,'','','');
        system.assertNotEquals(null, s, 'sdgDataProviderApexExampleTest:loadSDG returned null');

        system.debug(json.serialize(s));
        system.assertEquals(2, s.SDGFields.size(), 'Fields on example data provider');
        system.assertEquals(3, s.SDGActions.size(), 'Actions on example data provider');
        test.stopTest();

    }
    static testMethod void getData()
    {
        string tag = sdgDataProviderType.Apex.name() + ':sdgDataProviderApexExample';

        test.startTest();

        SDGREquest req = new SDGREquest();
        req.SDGTag = tag;

        req.pageid=1;
        req.pagesize=5;
        sdgresult sr = sdgDataProviderFactory.getData(req);
        system.assertEquals(0, sr.FullQueryCount, 'No Accounts to load');
        Account a = new Account();
        a.name = 'bob';
        insert a;
        Account a2 = new Account();
        a2.name = 'united';
        insert a2;
        sdgresult sr2 = sdgDataProviderFactory.getData(req);
        system.assertEquals(2, sr2.FullQueryCount, '2 Accounts to load');

        test.stopTest();


    }
}