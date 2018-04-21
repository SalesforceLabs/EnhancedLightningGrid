/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  config: function(cmp) {
    var isDesigner = false;

    try {
      //issues with IE
      if (window.location.href.indexOf("flexipage") > -1) {
        //cmp.set("v.ShowDesignPlaceholder", true);
        isDesigner = true;
      }
      if (window.location.href.indexOf("commeditor") > -1) {
        //cmp.set("v.ShowDesignPlaceholder", true);
        isDesigner = true;
      }
      if (isDesigner) {
        var thiscmp = cmp.find("placeholder");
        $A.util.addClass(thiscmp, "sdgdesignplaceholder");
      }
    } catch (err) {
      //suppress any errors
    }
  },
  handleError: function(component, ajaxresult) {
    var errors = ajaxresult.getError();

    if (errors) {
      if (errors[0] && errors[0].message) {
        var msg =
          "An unhandled error occurred in the AJAX call: " + errors[0].message;
        this.showtoast("Error", msg, component);
        this.AddToLog(component, msg);
      }
    }
  },
  callMethod: function(cmp, methodname, params, config, onSuccess) {
    var action = cmp.get(methodname);
    var configparams = {};
    if (typeof config === "object") {
      configparams = config;
    }
    action.setParams(params);

    this.AddToLog(cmp, methodname + ": " + JSON.stringify(params));

    if (configparams.isAbortable) {
      action.setAbortable();
    }
    if (configparams.isBackground) {
      action.setBackground();
    }
    if (configparams.isStorable) {
      action.setStorable();
    }
    var self = this;
    //Set up the callback
    action.setCallback(this, function(actionResult) {
      var state = actionResult.getState();
      var result = actionResult.getReturnValue();
      if (state === "SUCCESS") {
        self.AddToLog(cmp, methodname + " response: " + result);
        var resultobj = JSON.parse(result);
        if (resultobj != null) {
          if (onSuccess) onSuccess(resultobj);
        }
      } else if (state === "INCOMPLETE") {
        // do something
      } else if (state === "ERROR") {
        var errors = actionResult.getError();
        var msg = "";
        if (errors) {
          if (errors[0] && errors[0].message) {
            msg = "Error invoking " + methodname + ": " + errors[0].message;
            self.AddToLog(cmp, msg);
          }
        } else {
          msg = methodname + ": unknown error";
          self.AddToLog(cmp, msg);
        }
      }
    });

    $A.enqueueAction(action);
  },
  AddToLog: function(cmp, message) {
    var debugmode = cmp.get("v.ShowDebug");

    if (debugmode) {
      var log = cmp.get("v.DebugLog");
      var time = new Date();
      var timestring =
        time.getHours() +
        ":" +
        time.getMinutes() +
        ":" +
        time.getSeconds() +
        ":" +
        time.getMilliseconds();
      var counter = log.length + 1;
      log.unshift(counter + " " + timestring + " " + message);
      cmp.set("v.DebugLog", log);
    }
  }
});
