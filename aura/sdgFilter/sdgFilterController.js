({
    doInit: function (component, event, helper) {
        var FieldType = component.get("v.SDGField").FieldType;

        var pref = component.get("v.SDGField").Preferences;
        //suppress any exceptions during preference setting:
        try {
            if (pref != null) {
                component.set("v.FilterOperatorPreference", pref.FilterOperator);
                component.set("v.FilterValuePreference", pref.FilterValue);
                if (FieldType == 'DATE' || FieldType == 'DATETIME') {
                    if (pref.FilterValue != "")
                        component.set("v.DateValue", pref.FilterValue);
                }
            }
            else {
                component.set("v.FilterValuePreference", null);
            }

        }
        catch (err) {
            //Suppress errors in setting preferences
        }

        if (FieldType == 'DATE' || FieldType == 'DATETIME') {
            component.set("v.isDate", true);
            component.set("v.canFilter", true);

        }
        if (FieldType == 'INTEGER' || FieldType == 'DOUBLE' || FieldType == 'CURRENCY' || FieldType == 'PERCENT') {
            component.set("v.isNumber", true);
            component.set("v.canFilter", true);
        }
        if (FieldType == 'ID' || FieldType == 'STRING' || FieldType == 'EMAIL' || FieldType == 'URL' || FieldType == 'PHONE' || FieldType == 'HYPERLINK') {
            component.set("v.isString", true);
            component.set("v.canFilter", true);
        }
        //Other acceptable types
        if (FieldType == 'BOOLEAN' || FieldType == 'PICKLIST') {
            component.set("v.canFilter", true);
        }

    },
    
    reset: function (component, event, helper) {
        var FieldType = component.get("v.SDGField").FieldType;
        var operator = "";
        
        if (FieldType == 'DATE' || FieldType == 'DATETIME'){
            component.find("DateField").set("v.value", "");
            operator = component.find("DateOperatorField").get("v.value");
        }
        if (FieldType == 'INTEGER' || FieldType == 'DOUBLE' || FieldType == 'CURRENCY' || FieldType == 'PERCENT') {
            component.find("NumberField").set("v.value", "");
            operator = component.set("v.NumberOperator");
        }
        if (FieldType == 'ID' || FieldType == 'STRING' || FieldType == 'EMAIL' || FieldType == 'URL' || FieldType == 'PHONE' || FieldType == 'HYPERLINK') {
            component.find("StringField").set("v.value", "");
            operator = component.find("StringOperatorField").get("v.value");
        }
        if (FieldType == 'BOOLEAN'){
            component.find("CheckboxField").set("v.value", "");
        }
        if (FieldType == 'PICKLIST'){
            component.find("PicklistField").set("v.value", "");
        }
        
        helper.fireUpdate(component, "", operator);
    },

    updateString: function (component, event, helper) {
        var value = component.find("StringField").get("v.value");
        var operator = component.find("StringOperatorField").get("v.value");

        helper.fireUpdate(component, value, operator);
    },
    updateCheckbox: function (component, event, helper) {
        var value = component.find("CheckboxField").get("v.value");

        helper.fireUpdate(component, value, '');
    },
    updateDate: function (component, event, helper) {
        var value = component.find("DateField").get("v.value");
        if (value == null)
            value = '';
        var operator = component.find("DateOperatorField").get("v.value");

        helper.fireUpdate(component, value, operator);
    },
    updateNumber: function (component, event, helper) {
        var value = component.find("NumberField").get("v.value");
        var operator = component.get("v.NumberOperator");

        helper.fireUpdate(component, value, operator);
    },
    updatePicklist: function (component, event, helper) {
        var value = component.find("PicklistField").get("v.value");

        helper.fireUpdate(component, value, '');
    }


})