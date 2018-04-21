/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  LoadFields: function(component, objectname) {
    this.Busy(component);
    var action = component.get("c.GetSObjectFields");
    var sRecordId;

    //only do this this way so we can use setStorable on the call - otherwise we will have a different signature each sdg
    if (
      typeof objectname == "undefined" ||
      objectname === null ||
      objectname === ""
    ) {
      sRecordId = component.get("v.recordId");
    }
    action.setStorable();
    action.setAbortable();
    action.setParams({
      sObjectType: objectname,
      SDGRecordId: sRecordId
    });

    action.setCallback(this, function(actionResult) {
      if (actionResult.getState() === "SUCCESS") {
        var results = actionResult.getReturnValue();
        if (results !== null) {
          component.set("v.sObjectFields", results);
        }
        component.set("v.ShowFieldSelector", true);
        this.Ready(component);
      }
    });
    $A.enqueueAction(action);
  },
  Start: function(cmp) {
    var typeToUse = cmp.get("v.rootObjectType");

    this.LoadFields(cmp, typeToUse);
    cmp.set("v.selectedField", "");
    cmp.set("v.selectedPath", "");
    cmp.set("v.nodes", []);
    cmp.set("v.isValid", false);
    this.HideClear(cmp);
    this.ShowPicker(cmp);
  },
  HideClear: function(cmp) {
    cmp.set("v.showClear", false);
  },
  ShowClear: function(cmp) {
    cmp.set("v.showClear", true);
  },
  HidePicker: function(cmp) {
    var cmpTarget = cmp.find("sFieldSelector");
    $A.util.addClass(cmpTarget, "slds-hide");
  },
  ShowPicker: function(cmp) {
    var cmpTarget = cmp.find("sFieldSelector");
    $A.util.removeClass(cmpTarget, "slds-hide");
  },
  Busy: function(cmp) {
    cmp.set("v.PickerDisabled", true);
  },
  Ready: function(cmp) {
    cmp.set("v.PickerDisabled", false);
  }
});
