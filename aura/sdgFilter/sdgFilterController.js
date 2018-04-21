/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  doInit: function(component, event, helper) {
    var FieldType = component.get("v.SDGField").FieldType;

    var pref = component.get("v.SDGField").Preferences;
    //suppress any exceptions during preference setting:
    try {
      if (pref !== null) {
        component.set("v.FilterOperatorPreference", pref.FilterOperator);
        component.set("v.FilterValuePreference", pref.FilterValue);
        if (FieldType === "DATE" || FieldType === "DATETIME") {
          if (pref.FilterValue !== "")
            component.set("v.DateValue", pref.FilterValue);
        }
      } else {
        component.set("v.FilterValuePreference", null);
      }
    } catch (err) {
      //Suppress errors in setting preferences
    }

    if (FieldType === "DATE" || FieldType === "DATETIME") {
      component.set("v.isDate", true);
      component.set("v.canFilter", true);
    }
    if (
      FieldType === "INTEGER" ||
      FieldType === "DOUBLE" ||
      FieldType === "CURRENCY" ||
      FieldType === "PERCENT"
    ) {
      component.set("v.isNumber", true);
      component.set("v.canFilter", true);
    }
    if (
      FieldType === "ID" ||
      FieldType === "STRING" ||
      FieldType === "EMAIL" ||
      FieldType === "URL" ||
      FieldType === "PHONE" ||
      FieldType === "HYPERLINK"
    ) {
      component.set("v.isString", true);
      component.set("v.canFilter", true);
    }
    //Other acceptable types
    if (FieldType === "BOOLEAN" || FieldType === "PICKLIST") {
      component.set("v.canFilter", true);
    }
  },

  updateString: function(component, event, helper) {
    var value = component.find("StringField").get("v.value");
    var operator = component.find("StringOperatorField").get("v.value");

    helper.fireUpdate(component, value, operator);
  },
  updateCheckbox: function(component, event, helper) {
    var value = component.find("CheckboxField").get("v.value");

    helper.fireUpdate(component, value, "");
  },
  updateDate: function(component, event, helper) {
    var value = component.find("DateField").get("v.value");
    if (value === null) value = "";
    var operator = component.find("DateOperatorField").get("v.value");

    helper.fireUpdate(component, value, operator);
  },
  updateNumber: function(component, event, helper) {
    var value = component.find("NumberField").get("v.value");
    var operator = component.get("v.NumberOperator");

    helper.fireUpdate(component, value, operator);
  },
  updatePicklist: function(component, event, helper) {
    var value = component.find("PicklistField").get("v.value");

    helper.fireUpdate(component, value, "");
  }
});
