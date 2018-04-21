/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public class sdgMapper {
    public static SDGAction MapAction(sdg_action__c action)
    {
        SDGAction newAction = new SDGAction();
        newAction.Id = action.Id;
        newAction.label = action.name;
        newAction.event = action.event__c;
        try
        {
            newAction.actionOrder = integer.valueOf( action.action_order__c);
        }
        catch (exception ex)
        {
            newAction.actionOrder = 1;
        }
        
        newAction.Type = action.Action_Type__c;
        newAction.Payload = action.Event_Payload__c;
        newAction.Icon = action.Icon__c;
        return newAction;
    }
    public static SDGField MapField(Schema.DescribeFieldResult dr, String Path, String PathID, Boolean HideFilter, String OverrideLabel, String FieldStyle, Decimal fieldOrder)
    {
        
        SDGField newfield = new SDGField();
        newfield.Id = PathID;
        newfield.ColumnName = Path;
        newfield.FieldStyle = FieldStyle;
        try{
            newfield.FieldOrder = Integer.valueOf(fieldOrder);
        }
        catch(Exception ex)
        {
            newfield.FieldOrder = 1;
        }
        //handle scenario of invalid case
        newfield.ColumnName = path.removeEndIgnoreCase(dr.getName()) + dr.getName();
        
        newfield.fieldType= String.valueof(dr.getType());
        
        newfield.isHTMLFormatted = dr.isHtmlFormatted();
        newfield.canSort = dr.isSortable();
        newfield.canFilter = dr.isFilterable();
        if (HideFilter)
        {
            newfield.canFilter = false;
        }
        
        if (String.isBlank(OverrideLabel))
        {
            newfield.Label =dr.getLabel();
        }
        else
        {
            newfield.label = OverrideLabel;
        }
        
        if (newfield.fieldType ==String.valueOf(Schema.DisplayType.PICKLIST))
        {
            List<AuraSelectOption> options =getPicklistFieldOptions( dr);
            newfield.options = options;
        }
        if (string.isBlank(newfield.fieldType))
        {
            newfield = null;
        }
        return newfield;
    }
    
    public static List<AuraSelectOption>  getPicklistFieldOptions(Schema.DescribeFieldResult dr)
    {
        
        List<Schema.PicklistEntry> ple = dr.getPicklistValues();
        List<AuraSelectOption> options = new List<AuraSelectOption>();
        options.add(new AuraSelectOption('',''));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new AuraSelectOption(f.getLabel(), f.getValue()));
        }
        
        return options;
    }
    
    public static List<SDGAction> MapToSDGActions(String sObjectName, List<sdg_action__c> actions)
    {
        List<SDGAction> results = new List<SDGAction>();
        List<sdg_action__c> permittedactions  = sdgSecurity.PermittedActions(sObjectName, actions);
        for (SDG_Action__c action : permittedactions)
        {
            
            results.add(MapAction(action));
            
        } 
        return results;
        
    }
    public static List<SDGField> MapToSDGFields(Schema.SObjectType targetType,  List<SDG_Field__c> fields, Boolean updateInvalidFields)
    {
        List<SDGField> newFields = new List<SDGField>();
        
        Boolean needsupdate = false;
        
        for (SDG_Field__c field : fields)
        {
            
            try
            {
                sdgPathParser pp = new SDGPathParser(field.APIName__c, targetType);
                Schema.DescribeFieldResult dr = pp.getDescribe();
                //Just because it isn't accessible doesn't mean there's a problem - just means we don't return it to the UI
                if (dr.isAccessible())
                {
                    SDGField newfield = sdgMapper.MapField(dr, field.APIName__c, field.Id, field.Hide_Filter__c, field.Override_Label__c , field.Field_Style__c, field.fieldOrder__c);
                    if (newfield!=null)
                    {
                        newfield.Scale = dr.getScale();
                        newfields.add(newfield);
                    }
                }
            }
            catch (exception ex)
            {
                //Something bad with getting the field  - probably an invalid path - so for the time being mark the field as invalid so we don't hit this again
                if (updateInvalidFields)
                {
                    field.is_valid_field__c= false;
                    needsupdate = true;
                }
            }
            
        }
        //At least 1 field was invalid, so update db:
        if (needsupdate)
        {
            update fields;
        }
        return newfields;
    }
    
    public static SDG Convert(SDG__c core, List<SDG_Field__c> fields, List<sdg_action__c> actions, Boolean updateInvalidFields)
    {
        SDG CoreSDG = new SDG(core.sObjectName__c, core.Parent_Field_Name__c,  core.sobjectname__c,  core.Filter__c,  core.Default_Sort__c, core.Id, core.All_Rows__c );
        CoreSDG.internalData.DisableSharing = core.DisableSharing__c;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(CoreSDG.sObjectName);
        
        
        coreSDG.SDGFields = MapToSDGFields(targetType, fields, updateInvalidFields);
        coreSDG.SDGActions = MapToSDGActions(core.sObjectName__c, actions);
        
        
        return CoreSDG;
        
    }
}