/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public class sdgQueryBuilderTest {
    static testMethod void BuildFilterClauseString()
        {
            test.startTest();
            string result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', '=', '123');
            system.assertEquals(' abc = \'123\' ',result, 'STRING EQUALS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'NOT=', '123');
            system.assertEquals(' abc != \'123\' ',result, ' STRING NOT EQUALS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'CONTAINS', '123');
            system.assertEquals(' abc like \'%123%\' ',result, 'STRING CONTAINS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'NOTCONTAINS', '123');
            system.assertEquals(' (NOT abc like \'%123%\') ',result, 'STRING NOT CONTAINS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'STARTS', '123');
            system.assertEquals(' abc like \'123%\' ', result, 'STRING STARTS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'ENDS', '123');
            system.assertEquals(' abc like \'%123\' ',result, 'STRING ENDS');
            test.stopTest();
    }
    static testMethod void BuildFilterClauseNumber()
        {
            test.startTest();
            string result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', '=', '123');
            system.assertEquals(' abc = 123 ',result, 'NUMBER EQUALS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', 'GT', '123');
            system.assertEquals(' abc > 123 ',result, ' NUMBER GT');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', 'LT', '123');
            system.assertEquals(' abc < 123 ',result, 'NUMBER LT');
 
            result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', '=', '123.5');
            system.assertEquals(' abc = 123.5 ',result, 'DOUBLE EQUALS');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', 'GT', '123.5');
            system.assertEquals(' abc > 123.5 ',result, ' DOUBLE GT');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', 'LT', '123.5');
            system.assertEquals(' abc < 123.5 ',result, 'DOUBLE LT');

            test.stopTest();
    }

    static testMethod void BuildFilterClausePicklist()
        {
            test.startTest();
            string result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', 'HAPPY');
            system.assertEquals(' abc = \'HAPPY\' ',result, 'PICKLIST =');

            result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', '');
            system.assertEquals('  ',result, 'PICKLIST blank');

test.stopTest();
        }

        static testmethod void ProcessMergeFieldsTest()
        {
            test.startTest();
            string result = sdgQueryBuilder.ProcessMergeFields('select name from account', '123');
            system.assertEquals('select name from account',result, 'MergeFields No data');
            
            result = sdgQueryBuilder.ProcessMergeFields('a string #userid# to merge', '123');
            system.assertEquals('a string \'' + userinfo.getUserId() + '\' to merge',result, 'MergeFields userid');
            
            result = sdgQueryBuilder.ProcessMergeFields('select #Id# from account', '123');
            system.assertEquals('select 123 from account',result, 'MergeFields parentid');
            
            test.stopTest();
        }
}