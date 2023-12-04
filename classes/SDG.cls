/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class SDG
{
    global SDGInternal internalData ;
    global String sObjectName;
    global List<SDGAction> SDGActions;
    global List<SDGField> SDGFields;

    global SDG()
    {
        throw new sdgDeprecatedException('SDG requires a parameterized constructor');
    }

    global SDG(String sUniqueKey)
    {
        SDGInternal einternal = new SDGInternal();
        eInternal.sUniqueKey = sUniqueKey;
        this.internalData = einternal;
    }
    global SDG(String objectname, String ParentFieldName, String sObjectName, String sFilter, String sDefaultSort, String sUniqueKey)
    {
        this.sObjectName = objectName;

        SDGInternal einternal = new SDGInternal();
        einternal.ParentFieldName = ParentFieldName;
        eInternal.sObjectName = sObjectName;
        eInternal.sFilter = sFilter;
        eInternal.sDefaultSort = sDefaultSort;
        eInternal.sUniqueKey = sUniqueKey;
        eInternal.AllRows = false;
        this.internalData = einternal;
    }
    global SDG(String objectname, String ParentFieldName, String sObjectName, String sFilter, String sDefaultSort, String sUniqueKey, Boolean AllRows)
    {
        this.sObjectName = objectName;

        SDGInternal einternal = new SDGInternal();
        einternal.ParentFieldName = ParentFieldName;
        eInternal.sObjectName = sObjectName;
        eInternal.sFilter = sFilter;
        eInternal.sDefaultSort = sDefaultSort;
        eInternal.sUniqueKey = sUniqueKey;
        eInternal.AllRows = AllRows;
        this.internalData = einternal;
    }




}