/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  handleBuild: function(component, object, status, errorMessage) {
    //Add the new button to the body array
    if (status === "SUCCESS") {
      var body = component.get("v.body");
      body.push(object);
      component.set("v.body", body);
    } else if (status === "INCOMPLETE") {
      this.showError("No response from server or client is offline.");
      // Show offline error
    } else if (status === "ERROR") {
      this.showError("Error: " + errorMessage);
      // Show error message
    }
  },
  showError: function(msg) {
    var navToast = $A.get("e.force:showToast");
    navToast.setParams({
      title: "",
      message: msg,
      type: "error"
    });
    navToast.fire();
  },
  renderHyperLinktoObject: function(component, datachunk, datachunkid) {
    try {
      if (typeof datachunkid === "string" && typeof datachunk === "string") {
        if (datachunkid !== null && datachunk !== null) {
          if (datachunkid !== "" && datachunk !== "") {
            this.CreateCmp(component, "lightning:formattedUrl", {
              value: "/" + datachunkid,
              label: datachunk
            });
          }
        }
      }
      //}
      //}
    } catch (linkex) {
      this.showError("Error rendering hyperlinktoobject");
    }
  },
  getAddress: function(component, datachunk) {
    var outputarray = [];
    var addr = "";
    outputarray = this.addnonblank(outputarray, datachunk.street);
    outputarray = this.addnonblank(outputarray, datachunk.city);
    outputarray = this.addnonblank(outputarray, datachunk.state);
    outputarray = this.addnonblank(outputarray, datachunk.statecode);
    outputarray = this.addnonblank(outputarray, datachunk.country);

    if (outputarray.length > 0) {
      addr = outputarray.join(", ");
    }
    return addr;
  },
  addnonblank: function(arr, val) {
    if (val) {
      if (val !== "") {
        arr.push(val);
      }
    }
    return arr;
  },
  renderText: function(component, datachunk) {
    if (typeof datachunk === "string") {
      if (datachunk !== null) {
        this.CreateCmp(component, "lightning:formattedText", {
          value: datachunk,
          linkify: false
        });
      }
    }
  },
  renderNumber: function(component, datachunk, scale) {
    if (datachunk !== null) {
      this.CreateCmp(component, "lightning:formattedNumber", {
        value: datachunk,
        maximumFractionDigits: scale
      });
    }
  },
  renderPercent: function(component, datachunk, scale) {
    if (datachunk !== null) {
      if (datachunk !== "") {
        var percentvalue = datachunk / 100;
        this.CreateCmp(component, "lightning:formattedNumber", {
          value: percentvalue,
          style: "percent",
          maximumFractionDigits: scale
        });
      }
    }
  },
  renderSummaryText: function(component, summarytext) {
    if (typeof summarytext === "string") {
      if (summarytext !== null) {
        this.CreateCmp(component, "lightning:formattedText", {
          value: summarytext,
          class: "summary",
          linkify: false
        });
      }
    }
  },
  renderHyperLink: function(component, label, url) {
    if (typeof url === "string" && typeof label === "string") {
      if (url !== null && label !== null) {
        if (url !== "" && label !== "") {
          this.CreateCmp(component, "ui:outputURL", {
            value: url,
            label: label,
            target: "_blank"
          });
        }
      }
    }
  },
  formatDurationDateTime: function(cmp, dateRecord) {
    var sdgAgo = cmp.get("v.sdgAgo");
    var sdgIn = cmp.get("v.sdgIn");
    var dateNow = Date.now();
    var dur = $A.localizationService.duration(
      (dateNow - dateRecord) / (1000 * 60 * 60 * 24),
      "d"
    );
    var displayduration = $A.localizationService.displayDuration(dur);
    var output = "";
    if (dateNow - dateRecord > 0) {
      output = sdgAgo.replace("{0}", displayduration);
    } else {
      output = sdgIn.replace("{0}", displayduration);
    }
    return output;
  },
  CreateCmp: function(component, cmpType, cmpConfig) {
    var config = cmpConfig;
    if (config !== null) {
      config["aura:id"] = "findableAuraId";
      var self = this;

      $A.createComponent(cmpType, cmpConfig, function(
        cmp,
        status,
        errorMessage
      ) {
        self.handleBuild(component, cmp, status, errorMessage);
      });
    }
  }
});
