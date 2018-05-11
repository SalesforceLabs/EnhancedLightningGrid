/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  getNamespace: function(component) {
    var helper = this;
    try {
      this.callMethod(
        component,
        "c.GetNamespace",
        {},
        { isStorable: true, isAbortable: true },

        function(results) {
          if (results !== null) {
            component.set("v.namespace", results);
          }
        }
      );
    } catch (ex) {
      helper.AddToLog(component, "Error retrieving namespace: " + ex.message);
    }
  },
  getCoreParams: function(component) {
    var config = component.get("v.SDGConfiguration");
    if (config === undefined)
      config = "CustomObject:" + component.get("v.SDGTag");

    var params = {
      ParentRecordID: component.get("v.recordId"),
      SDGTag: config,
      RelationshipName: component.get("v.RelationshipName"),
      FieldSetName: component.get("v.FieldSetName")
    };
    return params;
  },
  getSDG: function(component) {
    this.Waiting(component);

    var params = this.getCoreParams(component);

    var sPageSize = "10";
    try {
      sPageSize = component.get("v.DefaultPageSize");
    } catch (PageSize) {
      //ignore
    }
    params.DefaultPageSize = sPageSize;

    component.set("v.isPaging", false);
    var thishelper = this;
    this.callMethod(
      component,
      "c.GetSDGInitialLoad",
      params,
      {
        isStorable: component.get("v.UseCache"),
        isAbortable: true,
        isBackground: component.get("v.UseBackground")
      },
      function(results) {
        if (results !== null) {
          if (results.isError) {
            thishelper.AddToLog(component, "Error: " + results.ErrorMessage);
            if (component.get("v.HideOnError")) {
              component.set("v.ShowComponent", false);
            }

            component.set("v.ShowSDGError", true);
            component.set("v.ErrorMessage", results.ErrorMessage);

            thishelper.showtoast("Error", results.ErrorMessage, component);
          } else {
            component.set("v.SDG", results.SDGObject);
            //Check Filters
            var fields = results.SDGObject.SDGFields;
            var fieldlistlength = fields.length;
            var hasFilters = false;
            var hasSummary = false;

            for (var i = 0; i < fieldlistlength; i++) {
              var field = fields[i];
              if (field.canFilter) hasFilters = true;
              if (
                field.FieldStyle &&
                field.FieldStyle.startsWith("Summarize")
              ) {
                hasSummary = true;
              }
            }
            component.set("v.hasSummary", hasSummary);
            component.set("v.hasFilters", hasFilters);
            //Set up Actions
            if (results.SDGObject.SDGActions !== null) {
              var listsize = results.SDGObject.SDGActions.length;

              var hasListMenu = false;
              var hasRowMenu = false;
              var hasRowActions = false;
              var hasMulti = false;

              component.set("v.SDGActions", results.SDGObject.SDGActions);
              for (var j = 0; j < listsize; j++) {
                var actiontype = results.SDGObject.SDGActions[j].Type;

                if (actiontype === "List") hasListMenu = true;
                if (actiontype === "List Multi") hasMulti = true;
                if (actiontype === "Row Button") hasRowActions = true;
                if (actiontype === "Row") {
                  hasRowMenu = true;
                  hasRowActions = true;
                }
              }
              component.set("v.hasRowMenu", hasRowMenu);
              component.set("v.hasListMenu", hasListMenu);
              component.set("v.hasRowActions", hasRowActions);
              component.set("v.MultiSelectMode", hasMulti);
            }

            component.set("v.isLoaded", true);
            thishelper.handleResults(component, results.Results);
          }
        } else {
          component.set("v.ShowSDGError", true);
          showtoast(
            "Error",
            "Cannot load configuration data:  Please reconfigure the component in the designer.",
            component
          );
        }
      }
    );
  },
  Waiting: function(component) {
    this.AddToLog(component, "Mode: Waiting");
    var table = component.find("sdgdatatablewrapper");
    $A.util.addClass(table, "working");
  },
  showtoast: function(title, message, component) {
    if (component.get("v.ShowComponent")) {
      var navtoast = $A.get("e.force:showToast");
      navtoast.setParams({
        title: title,
        message: message
      });

      navtoast.fire();
    }
  },
  DoneWaiting: function(component) {
    var table = component.find("sdgdatatablewrapper");
    $A.util.removeClass(table, "working");
    this.AddToLog(component, "Mode: DoneWaiting");
  },
  GetCaseInsensitiveAttr: function(obj, propname) {
    var propvalue;
    propname = (propname + "").toLowerCase();
    for (var p in obj) {
      if (obj.hasOwnProperty(p) && propname === (p + "").toLowerCase()) {
        propvalue = obj[p];
        break;
      }
    }
    return propvalue;
  },

  handleResults: function(component, resultsobj) {
    if (resultsobj.isError) {
      component.set("v.ShowSDGError", true);
      component.set("v.ErrorMessage", resultsobj.ErrorMessage);
      showtoast("Error", resultsobj.ErrorMessage, component);

      this.AddToLog(component, resultsobj.ErrorMessage);
      this.DoneWaiting(component);
      this.showtoast("", resultsobj.ErrorMessage, component);
    } else {
      var toggleButton = component.find("FilterToggleButton");

      if (resultsobj.isFiltered) {
        component.set("v.ToggleFilterStyle", "slds-is-selected");
      } else {
        component.set("v.ToggleFilterStyle", "");
      }

      //Now process the data into a list of data:
      var fields = component.get("v.SDG.SDGFields");
      var fieldlistlength = fields.length;

      var rows = [];
      // var dataurl;

      var payload = resultsobj.data;

      for (var rowcounter = 0; rowcounter < payload.length; rowcounter++) {
        var datarow = payload[rowcounter];
        var row = [];

        //dataurl = '';
        for (var i = 0; i < fieldlistlength; i++) {
          var field = fields[i];
          var fieldparts = field.ColumnName.split(".");
          var FieldName = fieldparts[fieldparts.length - 1];

          var datachunk = datarow;
          var datachunkid = null;
          var FormattedValue = null;
          for (var z = 0; z < fieldparts.length; z++) {
            if (datachunk) {
              if (z === fieldparts.length - 1) {
                if (datachunk["Id"]) datachunkid = datachunk["Id"];
                try {
                  if (field.FieldType === "CURRENCY") {
                    FormattedValue = this.GetCaseInsensitiveAttr(
                      datachunk,
                      fieldparts[z] + "Formatted"
                    );
                  }
                } catch (getFormattedEx) {
                  showtoast(
                    "Error",
                    "Unable to get formatted Currency",
                    component
                  );
                }
              }
              datachunk = this.GetCaseInsensitiveAttr(datachunk, fieldparts[z]);
              //This handles reference items on the record:
              if (field.FieldType === "REFERENCE") {
                datachunkid = datachunk;
              }
            } else {
              datachunk = null;
              datachunkid = null;
            }
          }

          row.push({
            Path: field.ColumnName,
            FieldType: field.FieldType,
            FieldLabel: field.Label + ": ",
            FieldName: FieldName,
            FieldStyle: field.FieldStyle,
            FormattedValue: FormattedValue,
            datachunk: datachunk,
            datachunkid: datachunkid,
            isHTMLFormatted: field.isHTMLFormatted,
            scale: field.scale
          });
        }

        //add to array
        rows.push({
          rowID: datarow["Id"],
          data: row
        });
      }
      var generateSummary = component.get("v.hasSummary");

      var summaryrow = [];

      if (generateSummary) {
        for (var j = 0; j < fieldlistlength; j++) {
          var summaryvalue = 0;
          field = fields[j];
          var coltotal = 0;
          var colmin = null;
          var colmax = null;
          var prefix = "";
          if (field.FieldStyle && field.FieldStyle.startsWith("Summarize")) {
            //Add the fields up:

            for (
              var rowsummarizer = 0;
              rowsummarizer < payload.length;
              rowsummarizer++
            ) {
              var val = rows[rowsummarizer].data[i].datachunk;

              if (typeof val === "number" || typeof val === "currency") {
                coltotal += val;
                colmin = Math.min(colmin === null ? val : colmin, val);
                colmax = Math.max(colmax === null ? val : colmax, val);
              }
            }

            if (field.FieldStyle === "Summarize:Total") {
              summaryvalue = coltotal.toFixed(2);
              prefix = "Total: ";
            }

            if (field.FieldStyle === "Summarize:Average") {
              prefix = "Avg: ";
              if (payload.length > 0)
                summaryvalue = (coltotal / payload.length).toFixed(2);
            }
            if (field.FieldStyle === "Summarize:Max") {
              prefix = "Max: ";
              summaryvalue = colmax;
            }
            if (field.FieldStyle === "Summarize:Min") {
              prefix = "Min: ";
              summaryvalue = colmin;
            }
          } else {
            summaryvalue = "";
            prefix = "";
          }
          summaryrow.push({
            FieldType: "SUMMARY",
            FieldLabel: "",
            datachunk: summaryvalue,
            Path: "",
            FieldName: "",
            FieldStyle: "",
            datachunkid: "",
            FormattedValue: prefix + summaryvalue,
            isHTMLFormatted: false
          });
        }
      }
      component.set("v.summarydata", summaryrow);
      component.set("v.FullQueryCount", resultsobj.FullQueryCount);

      this.AddToLog(
        component,
        "Query returns: " + resultsobj.FullQueryCount + " rows"
      );
      //current page:
      if (component.get("v.isPaging") === false) {
        var opts = [];
        for (j = 0; j < resultsobj.pagecount; j++) {
          opts.push({ label: j + 1, value: j + 1 });
        }
        //Bind to the component
        component.set("v.Pages", opts);
        var pp = component.find("PagerPage");
        if (pp) {
          pp.set("v.value", "1");
        }
      }
      component.set("v.isPaging", false);
      component.set("v.processeddata", rows);

      var newTitle = component.get("v.Title");
      newTitle =
        newTitle + " " + " (" + component.get("v.FullQueryCount") + ")";
      component.set("v.TitleName", newTitle);

      this.DoneWaiting(component);
    }
  },

  getResponseData: function(component) {
    var thishelper = this;
    try {
      this.Waiting(component);

      var params = this.getCoreParams(component);

      params.PageID = parseInt(component.find("PagerPage").get("v.value"), 10);
      params.Filters = component.get("v.SDGFilters");
      params.PageSize = parseInt(
        component.find("PagerSize").get("v.value"),
        10
      );
      params.SortOrder = component.get("v.SortOrder");
      params.SortColumn = component.get("v.SortColumn");
      params.reloadseed = component.get("v.reloadseed");

      if (component.get("v.SDGFilters").length > 0) {
        component.set("v.FilterButtonClass", "slds-is-selected");
      } else {
        component.set("v.FilterButtonClass", "");
      }

      var req = { jsonrequest: JSON.stringify(params) };

      this.callMethod(
        component,
        "c.getSDGResult",
        req,
        {
          isStorable: component.get("v.UseCache"),
          isAbortable: true,
          isBackground: component.get("v.UseBackground")
        },
        function(results) {
          thishelper.handleResults(component, results);
        }
      );
    } catch (getResponseDataErr) {
      thishelper.AddToLog(component, "Error: " + getResponseDataErr.message);
    }
  },

  FireEvent: function(component, actionid, datarow) {
    var evt;
    var actions = component.get("v.SDG.SDGActions");
    var opts = [];
    for (var i = 0; i < actions.length; i++) {
      if (actions[i].Id === actionid) {
        evt = actions[i];
      }
    }

    if (evt != null) {
      //build payload:
      var payload = evt.Payload;
      payload = payload.replace(
        /#parentrecordId#/gi,
        component.get("v.recordId")
      );

      var idlist = component.get("v.CheckedRowIDs");
      payload = payload.replace(/#Ids#/gi, idlist.join());

      if (datarow) {
        payload = payload.replace(/#Id#/gi, datarow.rowID);
      }

      if (datarow) {
        for (var fieldkey in datarow.data) {
          var field = datarow.data[fieldkey];
          payload = payload.replace("#" + field.Path + "#", field.datachunk);
          try {
            //this only works in Chrome/FF/Edge+ - ie no IE
            if (field.Path.lastIndexOf("Name") === field.Path.length - 4) {
              //if (field.Path.endsWith('Name'))
              var newpath =
                field.Path.substring(0, field.Path.length - 4) + "Id";

              if (field.datachunkid)
                payload = payload.replace(
                  "#" + newpath + "#",
                  field.datachunkid
                );
            }
          } catch (endwithex) {
            //ignore - this is a javascript problem - probably IE
          }
        }
      }

      var payloadobj = JSON.parse(payload);
      var internalevent = component.get("v.internalEvent");
      if (evt.Event !== internalevent) {
        var navEvt = $A.get(evt.Event);

        if (navEvt === null) {
          this.showtoast(
            "Error",
            "Invalid event name - cannot identify event",
            component
          );
        } else {
          navEvt.setParams(payloadobj);
          navEvt.fire();
        }
      } else {
        var objhelper = component.find("ObjectHelper");
        objhelper.doMethod(payloadobj);
      }
    }
  },

  RaiseRowEvent: function(component, helper, valuesString) {
    var values = valuesString.split(",");
    var actionid = values[0];
    var rowID = values[1];
    //get the data row:
    var allrows = component.get("v.processeddata");
    var selectedrow;
    for (var key in allrows) {
      var datarow = allrows[key];
      if (datarow.rowID === rowID) {
        selectedrow = datarow;
      }
    }

    this.FireEvent(component, actionid, selectedrow);
  }
});
