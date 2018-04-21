/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class AuraFieldSelectOption implements Comparable {
    global AuraFieldSelectOption(String fieldname, String objectname,  String label) {
        this.fieldname = fieldname;
        this.objectname = objectname;
        this.label = label;
    }

    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String fieldname { get;set; }
    @AuraEnabled
    public String objectname { get;set; }


    public Integer compareTo(Object compareTo) {
        AuraFieldSelectOption compareToASO = (AuraFieldSelectOption)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (label > compareToASO.label) {
            returnValue = 1;
        } else if (compareToASO.label>label) {
            // Set return value to a negative value.
            returnValue = -1;
        }

        return returnValue;
    }

}