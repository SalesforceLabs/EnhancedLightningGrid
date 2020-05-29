/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
@isTest
public class sdgFilterTest {

    static testMethod void GetCreate()
    {
        test.startTest();
        SDGFilter f = new SDGFilter();
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFilterTest: Expected a SDGFilter to be created.');

    }

 	static testMethod void GetCreateFull()
    {
        test.startTest();
        SDGFilter f = new SDGFilter('1', '=', 'APPLE');
        test.stopTest();
        system.assertNotEquals(null,f, 'SDGFilterTest:GetCreateFull: Expected a rich SDGFilter to be created.');
        system.assertEquals('=', f.filterOperator, 'SDGFilterTest:GetCreateFull: Expected filteroperator to be saved ');
        system.assertEquals('APPLE', f.filterValue, 'SDGFilterTest:GetCreateFull: Expected filtervalue to be saved ');
    }
}