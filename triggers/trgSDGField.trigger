/*
Sortable Data Grid
Copyright ©  21 November 2017

All rights reserved
*/
trigger trgSDGField on SDG_Field__c (before insert, before update) {

    sdgVerification.VerifySDGFields(trigger.new, false);

}