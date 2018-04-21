/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  doInit: function(component, event, helper) {
    var TargetSize = component.get("v.width");
    var DisableResponsive = component.get("v.PreventResponsiveness");

    if (DisableResponsive) {
      TargetSize = "LARGE";
    } else {
      if (TargetSize === undefined) {
        var formFactor = $A.get("$Browser.formFactor");

        TargetSize = "MEDIUM";
        if (formFactor === "PHONE") {
          TargetSize = "SMALL";
        }
        if (formFactor === "DESKTOP") {
          TargetSize = "LARGE";
        }
      }
    }

    component.set("v.TargetSize", TargetSize);

    if (TargetSize === "LARGE") component.set("v.filtersize", 4);
    if (TargetSize === "MEDIUM") component.set("v.filtersize", 6);
    if (TargetSize === "SMALL") component.set("v.filtersize", 12);

    component.set("v.TitleName", component.get("v.Title"));

    helper.getSDG(component);
    helper.getNamespace(component);
  },
  handleObjectManagerEvent: function(component, event, helper) {},
  paging: function(component, event, helper) {
    component.set("v.isPaging", true);
    helper.getResponseData(component);
  },
  CreateNew: function(component, event, helper) {
    var navEvt = $A.get("e.force:createRecord");

    var objname = component.get("v.SDG").sObjectName;
    navEvt.setParams({
      entityApiName: objname,
      recordTypeId: null
    });
    navEvt.fire();
  },
  reload: function(component, event, helper) {
    component.set("v.reloadseed", Date.now());
    helper.getResponseData(component);
  },
  filterUpdated: function(component, event, helper) {
    component.set("v.ShowSDGError", false);
    var filters = component.get("v.SDGFilters");
    var filterlistlength = filters.length;
    var newfilters = [];
    var newSDGFieldID = event.getParam("SDGFieldID");

    // create a map to deduplicate here...
    for (var i = 0; i < filterlistlength; i++) {
      if (filters[i].SDGFieldID !== newSDGFieldID) {
        newfilters.push(filters[i]);
      }
    }

    //Add the new value:
    var newfilter = {
      FilterValue: event.getParam("FilterValue"),
      FilterOperator: event.getParam("FilterOperator"),
      SDGFieldID: event.getParam("SDGFieldID")
    };
    newfilters.push(newfilter);
    component.set("v.SDGFilters", newfilters);
    helper.AddToLog(component, "Filters updated");
    helper.getResponseData(component);
  },
  handleSort: function(cmp, event, helper) {
    var val = event.getParam("value");
    var vals = val.split(":");
    cmp.set("v.SortColumn", vals[0]);
    cmp.set("v.SortOrder", vals[1]);
    helper.getResponseData(cmp);
  },
  sort: function(component, event, helper) {
    component.set("v.SortColumn", event.getParam("SDGFieldID"));
    component.set("v.SortOrder", event.getParam("SortOrder"));
    helper.getResponseData(component);
  },
  ClearFilters: function(component, event, helper) {
    var filters = component.find("cmpFilter");

    if (filters) {
      var filterlistlength = filters.length;

      // clear the values
      for (var i = 0; i < filterlistlength; i++) {
        filters[i].set("v.FilterValue", "");
      }

      helper.AddToLog(component, "Filters cleared");
    }
  },
  checkboxchange: function(component, event, helper) {
    var idlist = component.get("v.CheckedRowIDs");
    if (event.getSource().get("v.checked")) {
      idlist.push(event.getSource().get("v.value"));
    } else {
      var index = idlist.indexOf(event.getSource().get("v.value"));
      idlist.splice(index, 1);
    }
    component.set("v.CheckedRowIDs", idlist);
  },
  ToggleDebug: function(component, event, helper) {
    var cmpTarget = component.find("debuglogpanel");

    $A.util.toggleClass(cmpTarget, "debugsize");
  },
  ToggleFilters: function(component, event, helper) {
    //Determine whether to show the filters:
    var FiltersSet = component.get("v.SDGFiltersDefinition");
    if (FiltersSet.length === 0) {
      var SDGObject = component.get("v.SDG");
      component.set("v.SDGFiltersDefinition", SDGObject.SDGFields);
    }

    var newvalue = !component.get("v.ShowFilters");
    var cmpTarget = component.find("FilterToggle");

    if (newvalue) {
      $A.util.addClass(cmpTarget, "slds-is-selected");
      $A.util.removeClass(cmpTarget, "slds-not-selected");
    } else {
      $A.util.removeClass(cmpTarget, "slds-is-selected");
      $A.util.addClass(cmpTarget, "slds-not-selected");
    }
    component.set("v.ShowFilters", newvalue);
  },
  CheckAll: function(component, event, helper) {
    //var idlist = component.get("v.CheckedRowIDs");

    var idlist = [];
    var checkboxes = component.find("checkrow");
    var checkboxeslength = checkboxes.length;
    var targetstate = event.getSource().get("v.checked");
    for (var i = 0; i < checkboxeslength; i++) {
      checkboxes[i].set("v.checked", targetstate);
      idlist.push(checkboxes[i].get("v.value"));
    }

    if (!targetstate) {
      idlist = [];
    }

    component.set("v.CheckedRowIDs", idlist);
  },
  ShowAll: function(component, event, helper) {
    var evt = $A.get("e.force:navigateToComponent");
    var c = component;

    evt.setParams({
      componentDef: "c:sdgList",
      componentAttributes: {
        SDGConfiguration: c.get("v.SDGConfiguration"),
        HideOnError: false,
        recordId: c.get("v.recordId"),
        Title: c.get("v.Title"),
        ShowDebug: c.get("v.ShowDebug"),
        UseCache: c.get("v.UseCache"),
        FieldSetName: c.get("v.FieldSetName"),
        SVGName: c.get("v.SVGName")
      }
    });
    evt.fire();
  },
  RaiseListEventMenu: function(component, event, helper) {
    var menuItem = event.detail.menuItem;
    var actionid = menuItem.get("v.value");
    helper.FireEvent(component, actionid);
  },
  RaiseListEventButton: function(component, event, helper) {
    var actionid = event.getSource().get("v.value");
    helper.FireEvent(component, actionid);
  },
  RaiseListMultiEventButton: function(component, event, helper) {
    var actionid = event.getSource().get("v.value");
    helper.FireEvent(component, actionid);
  },
  RaiseRowEventMenu: function(component, event, helper) {
    var menuItem = event.detail.menuItem;
    var valuesString = menuItem.get("v.value");
    helper.RaiseRowEvent(component, helper, valuesString);
  },
  RaiseRowEventButton: function(component, event, helper) {
    var valuesString = event.getSource().get("v.value");
    helper.RaiseRowEvent(component, helper, valuesString);
  }
});
