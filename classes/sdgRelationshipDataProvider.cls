/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class sdgRelationshipDataProvider implements sdgDataProvider {

    global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {
        throw new sdgDeprecatedException('sdgRelationshipDataProvider is Deprecated');
    }

    global  SDG LoadSDG(SDG coreSDG)
    {
         throw new sdgDeprecatedException('sdgRelationshipDataProvider is Deprecated');

    }
    global   SDG LoadSDG(String ParentRecordID, String RelationshipName, String FieldSetName)
    {
         throw new sdgDeprecatedException('sdgRelationshipDataProvider is Deprecated');
    }

}