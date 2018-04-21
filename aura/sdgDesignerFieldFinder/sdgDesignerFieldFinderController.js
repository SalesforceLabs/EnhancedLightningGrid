/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  doInit: function(component, event, helper) {
    var action = component.get("c.GetNamespace");
    action.setStorable();
    action.setAbortable();

    action.setCallback(this, function(actionResult) {
      if (actionResult.getState() === "SUCCESS") {
        var results = actionResult.getReturnValue();
        if (results != null) {
          component.set("v.namespace", results);
        }
      }
    });
    $A.enqueueAction(action);
  },
  AddField: function(component, event, helper) {
    //Get new Field Order ID:
    var action = component.get("c.GetNewFieldOrder");
    action.setAbortable();
    action.setParams({
      SDGRecordId: component.get("v.recordId")
    });

    action.setCallback(this, function(actionResult) {
      if (actionResult.getState() === "SUCCESS") {
        var newID = actionResult.getReturnValue();

        //create and raise event
        var createRecordEvent = $A.get("e.force:createRecord");
        var defaultFieldValues = {};

        var namespace = component.get("v.namespace");
        defaultFieldValues[namespace + "sdg__c"] = component.get("v.recordId");
        defaultFieldValues[namespace + "APIName__c"] = component.get(
          "v.selectedPath"
        );
        defaultFieldValues[namespace + "FieldOrder__c"] = newID;

        createRecordEvent.setParams({
          entityApiName: namespace + "SDG_Field__c",
          defaultFieldValues: defaultFieldValues,
          navigationLocation: "RELATED_LIST"
        });
        createRecordEvent.fire();
        var picker = component.find("picker");
        picker.clearselection();
      }
    });
    $A.enqueueAction(action);
  }
});
