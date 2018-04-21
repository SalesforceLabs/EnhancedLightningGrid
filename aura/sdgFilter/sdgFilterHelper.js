/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  getERLPicklist: function(component) {
    var action = component.get("c.getPicklistOptions");
    action.setParams({
      SDGFieldID: component.get("v.SDGField.Id")
    });

    //Set up the callback
    var self = this;
    action.setCallback(this, function(actionResult) {
      results = JSON.parse(actionResult.getReturnValue());
      component.set("v.picklistvalues", results);
    });
    $A.enqueueAction(action);
  },
  fireUpdate: function(component, paramvalue, paramoperator) {
    if (paramvalue == null) {
      paramvalue = "";
    }
    var compEvent = component.getEvent("SDGFilterUpdate");
    compEvent.setParams({
      SDGFieldID: component.get("v.SDGField").ID,
      FilterOperator: paramoperator,
      FilterValue: paramvalue
    });
    compEvent.fire();
  }
});
