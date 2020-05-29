/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
global interface sdgDataProvider {
    SDGResult getData(SDG coreSDG, SDGRequest request);
    SDG LoadSDG(SDG coreSDG);
}