/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class SDGRequest
{
    global String RelationshipName = '';
    global String FieldSetName = '';
    global String SDGTag = '';
    global String ParentRecordID = '';
    global String ParentFieldName = '';
    global List<SDGFilter> Filters;

    global SDGRequest()
    {

    }

    global integer PageID  = 1;
    global integer PageSize  = 10;
    global String SortColumn = '';
    global String SortOrder = '';
}