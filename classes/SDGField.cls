/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class SDGField implements Comparable
{
global string ID ;
global string Label;
global string ColumnName;
global string FieldType;
global string FilterType; //NOT USED
global string FieldStyle;
global Boolean isHTMLFormatted;
global SDGFilter Preferences;
global Boolean canSort = false;
global Boolean canFilter = false;
global List<AuraSelectOption> options = new List<AuraSelectOption>();
global integer FieldOrder;
global integer scale;

public sdgField()
{

}

global sdgField(String ID, String Label, String ColumnName, String FieldType, String FieldStyle, Boolean canSort, List<AuraSelectOption> options)
{
    throw new sdgDeprecatedException('SDGField:Constructor signature no longer supported');
}
global sdgField(String ID, String Label, String ColumnName, String FieldType, String FieldStyle, Boolean canSort, Boolean isHTMLFormatted, List<AuraSelectOption> options)
{
    this.ID = ID;
    this.Label = Label;
    this.ColumnName = ColumnName;
    this.FieldType = FieldType;
    this.FieldStyle = FieldStyle;
    this.isHTMLFormatted = isHTMLFormatted;
    this.canSort = canSort;
    this.FieldOrder = 1;
}
    global sdgField(String ID, String Label, String ColumnName, String FieldType, String FieldStyle, Boolean canSort, Boolean isHTMLFormatted, List<AuraSelectOption> options, integer FieldOrder)
{
    this.ID = ID;
    this.Label = Label;
    this.ColumnName = ColumnName;
    this.FieldType = FieldType;
    this.FieldStyle = FieldStyle;
    this.isHTMLFormatted = isHTMLFormatted;
    this.canSort = canSort;
    this.FieldOrder = FieldOrder;
}

    global sdgField(String ID, String Label, String ColumnName, String FieldType, String FieldStyle, Boolean canSort, Boolean canFilter, Boolean isHTMLFormatted, List<AuraSelectOption> options, integer FieldOrder)
{
    this.ID = ID;
    this.Label = Label;
    this.ColumnName = ColumnName;
    this.FieldType = FieldType;
    this.FieldStyle = FieldStyle;
    this.isHTMLFormatted = isHTMLFormatted;
    this.canSort = canSort;
    this.canFilter = canFilter;
    this.FieldOrder = FieldOrder;
}
// Compare action based on the actionorder.
public Integer compareTo(Object compareTo) {
    // Cast argument to wrapper
    sdgField compareToField = (sdgField)compareTo;
    
    // The return value of 0 indicates that both elements are equal.
    Integer returnValue = 0;
    if (FieldOrder > compareToField.FieldOrder) {
        // Set return value to a positive value.
        returnValue = 1;
    } else if (FieldOrder < compareToField.FieldOrder) {
        // Set return value to a negative value.
        returnValue = -1;
    }
    
    return returnValue;       
}
}