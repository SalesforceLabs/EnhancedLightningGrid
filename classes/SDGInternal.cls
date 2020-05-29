/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
public with sharing class SDGInternal
{
    public string ParentFieldName;
    public string sObjectName;
    public string sDefaultSort;
    public string sFilter;
    public string sUniqueKey;
    public boolean AllRows = false;
    public boolean DisableSharing = false;
}