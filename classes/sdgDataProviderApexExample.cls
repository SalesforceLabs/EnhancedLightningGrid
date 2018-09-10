/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgDataProviderApexExample implements sdgIDataProvider {
        global static Boolean isUserSelectable()
    {
        return true;
    }

    global static SDGResult getData(SDG coreSDG,  SDGRequest request)
    {
        SDGResult result = new SDGResult();

        integer dataoffset = request.pageid * request.pagesize;
        integer datalimit = request.PageSize;
        sdgSecurity.CanQuery('sdgDataProviderApexExample:getData', 'Account', '', 'name', '', true);

        //This is commented to allow installation on an org where name is encrypted.         
        result.data = [select name from account  ];

        result.query='sdgDataProviderApexExample';
        result.FullQueryCount = result.data.size();
        result.pagecount = 1;
        result.isError = false;
        result.ErrorMessage = '';
        return result;
    }

    global   SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        system.debug('sdgDataProviderApexExample:LoadSDG');
        SDG CoreSDG = new SDG( 'sdgDataProviderApexExample' );

        CoreSDG.SDGActions = getActions();
        CoreSDG.SDGFields = getFields();
        return CoreSDG;
    }

    private List<SDGAction> GetActions()
    {
        List<SDGAction> actions = new List<SDGAction>();

        actions.add(new SDGAction('1', 'New', 'e.force:createRecord', 'List Button', '{"entityApiName": "Contact"}', 'utility:new', 1));
        actions.add(new SDGAction('2', 'Edit', 'e.force:editRecord', 'Row Button', '{"recordId": "#Id#"}', 'utility:edit', 2));
        actions.add(new SDGAction('3', 'Edit2', 'e.force:editRecord', 'Row Button', '{"recordId": "#Id#"}', 'utility:edit',3 ));

        return actions;
    }

    private List<SDGField> GetFields()
    {
        List<SDGField> fields = new List<SDGField>();
        fields.add(new SDGField('1', 'My Name override', 'name', 'STRING', '', false, false, null, 1));
        fields.add( new SDGField('2', 'My ID override', 'Id', 'STRING', '', false, false, null, 2));

        return fields;
    }

}