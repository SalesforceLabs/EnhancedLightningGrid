/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class SDGResult
{
    global List<sObject> data;
    global string query;
    global integer FullQueryCount;
    global integer pagecount;
    global Boolean isFiltered;
    global Boolean isError;
    global String ErrorMessage;
}