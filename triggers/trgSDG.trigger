/*
Sortable Data Grid
Copyright ©  21 November 2017

All rights reserved
*/
trigger trgSDG on SDG__c (before insert, before update) {
    sdgVerification.VerifySDG(trigger.new, false);

}