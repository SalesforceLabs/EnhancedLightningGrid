/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class SDGFilter
{
    global string SDGFieldID;
    global string FilterOperator;
    global string FilterValue;

global SDGFilter()
{

}
    global SDGFilter(string SDGFieldID, string FilterOperator, string FilterValue)
    {
        this.SDGFieldID = SDGFieldID;
        this.FilterOperator = FilterOperator;
        this.FilterValue = FilterValue;
    }


}