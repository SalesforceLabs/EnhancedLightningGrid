/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global with sharing class sdgNativeDataProvider implements sdgDataProvider {

        global static SDGResult getData(SDG CoreSDG, SDGRequest request)
    {
        throw new sdgDeprecatedException('sdgNativeDataProvider is Deprecated');
    }

     global SDG LoadSDG(SDG coreSDG)
    {
         throw new sdgDeprecatedException('sdgNativeDataProvider is Deprecated');

    }

}