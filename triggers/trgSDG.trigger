/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
trigger trgSDG on SDG__c (before insert, before update) {
    sdgVerification.VerifySDG(trigger.new, false);

}