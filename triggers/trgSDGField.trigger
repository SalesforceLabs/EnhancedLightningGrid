/*
Sortable Data Grid
Copyright © Felix Lindsay 21 November 2017
flindsay@gmail.com
All rights reserved
*/
trigger trgSDGField on SDG_Field__c (before insert, before update) {

    sdgVerification.VerifySDGFields(trigger.new, false);

}