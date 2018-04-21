/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  doInit: function(component, event, helper) {
    helper.Start(component);
  },
  clear: function(component, event, helper) {
    helper.Start(component);
  },

  sFieldChanged: function(component, event, helper) {
    helper.HidePicker(component);

    var selecteditem = component.get("v.selectedField");

    var existingpath = component.get("v.selectedPath");
    if (existingpath !== "") {
      existingpath = existingpath + ".";
    }
    existingpath = existingpath + selecteditem;
    component.set("v.selectedPath", existingpath);
    var nodes = component.get("v.nodes");
    nodes.push(selecteditem);
    component.set("v.showClear", true);
    component.set("v.nodes", nodes);

    //Get the current selected node:
    var fields = component.get("v.sObjectFields");
    var selectedfield = fields.filter(function(obj) {
      return obj.fieldname === selecteditem;
    });

    if (selectedfield[0].objectname !== "") {
      helper.LoadFields(component, selectedfield[0].objectname);
      component.set("v.isValid", false);
      helper.ShowPicker(component);
    } else {
      helper.HidePicker(component);
      component.set("v.isValid", true);
    }
  }
});
