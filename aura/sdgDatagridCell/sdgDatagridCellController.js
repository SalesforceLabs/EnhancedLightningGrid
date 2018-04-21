/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  onInit: function(component, event, helper) {
    try {
      var field = component.get("v.renderfield");
      var fieldtype = field.FieldType;
      var fieldstyle = field.FieldStyle;
      if (!field) {
        helper.CreateCmp("ui:outputText", { value: "no data" });
      } else {
        var datachunk = field.datachunk;
        var datachunkid = field.datachunkid;

        var fieldurl = field.url;
        var objid = field.ObjId;

        if (!datachunk) datachunk = "";

        if (field.isHTMLFormatted) {
          helper.CreateCmp(component, "aura:unescapedHtml", {
            value: datachunk
          });
        } else {
          switch (fieldtype) {
            case "STRING":
              if (field.FieldName.toLowerCase() === "name") {
                helper.renderHyperLinktoObject(
                  component,
                  datachunk,
                  datachunkid
                );
              } else {
                helper.renderText(component, datachunk);
              }
              break;
            case "COMBOBOX":
              helper.renderText(component, datachunk);
              break;
            case "ANYTYPE":
              helper.renderText(component, datachunk);
              break;
            case "SUMMARY":
              helper.renderSummaryText(component, field.FormattedValue);
              break;
            case "ID":
              helper.renderHyperLinktoObject(
                component,
                datachunkid,
                datachunkid
              );
              break;
            case "REFERENCE":
              helper.renderText(component, datachunk);
              break;
            case "PERCENT":
              helper.renderPercent(component, datachunk, field.scale);
              break;
            case "ENCRYPTEDSTRING":
              helper.renderText(component, datachunk);
              break;
            case "INTEGER":
              helper.renderNumber(component, datachunk, 0);
              break;
            case "MULTIPICKLIST":
              helper.renderText(component, datachunk);
              break;
            case "PICKLIST":
              helper.renderText(component, datachunk);
              break;
            case "ADDRESS":
              var label = helper.getAddress(component, datachunk);
              var url =
                "https://www.google.com/maps/search/?api=1&query=" +
                encodeURIComponent(label);
              helper.renderHyperLink(component, label, url);
              break;
            case "CURRENCY":
              if (field.FormattedValue !== null) {
                try {
                  helper.renderText(component, field.FormattedValue);
                } catch (currencyex) {
                  helper.showError("Unable to render currency");
                }
              }
              break;
            case "DATE":
              try {
                //Dates are unusual - they aren't timezone dependent, but the nice rendering libraries are - so have to slightly hack this.
                if (datachunk) {
                  if (datachunk !== "") {
                    var datevalue = $A.localizationService.parseDateTime(
                      datachunk
                    );
                    if (datevalue !== "NaN") {
                      //var dateoffsetcalc = new Date();
                      //var offset = dateoffsetcalc.getTimezoneOffset();
                      //datevalue = datevalue + (offset * 60 * 1000);
                      if (fieldstyle === "Age") {
                        helper.renderText(
                          component,
                          helper.formatDurationDateTime(component, datevalue)
                        );
                      } else {
                        //Render this date WITHOUT a timezone
                        helper.CreateCmp(
                          component,
                          "lightning:formattedDateTime",
                          {
                            value: datevalue,
                            year: "numeric",
                            month: "short",
                            day: "numeric"
                          }
                        );
                      }
                    }
                  }
                }
              } catch (dateex) {
                helper.showError("Error parsing date");
              }

              break;
            case "TIME":
              try {
                if (datachunk) {
                  if (datachunk !== "") {
                    helper.renderText(component, datachunk);
                    /*var datevalue = '2000-01-15T' + datachunk;
                                    var timezone = $A.get("$Locale.timezone");
                                    helper.CreateCmp(component,
                                        "lightning:formattedDateTime",
                                        { "value": datevalue, timeZone: timezone, timeZoneName: "short", hour: "numeric", minute: "numeric", second: "numeric" }
                                    );*/
                  }
                }
              } catch (dateex) {
                helper.showError("Error parsing time");
              }

              break;
            case "DATETIME":
              try {
                var datetimevalue = $A.localizationService.parseDateTime(
                  datachunk
                );
                if (datetimevalue !== "NaN") {
                  if (fieldstyle === "Age") {
                    helper.renderText(
                      component,
                      helper.formatDurationDateTime(component, datetimevalue)
                    );
                  } else {
                    var timezone = $A.get("$Locale.timezone");
                    helper.CreateCmp(component, "lightning:formattedDateTime", {
                      value: datetimevalue,
                      timeZone: timezone,
                      year: "numeric",
                      month: "short",
                      day: "numeric",
                      hour: "numeric",
                      minute: "numeric",
                      second: "numeric"
                    });
                  }
                }
              } catch (dateex) {
                helper.showError("Error parsing datetime");
              }
              break;
            case "DOUBLE":
              try {
                helper.renderNumber(component, datachunk, field.scale);
              } catch (numex) {
                helper.showError("Unable to render double");
              }
              break;
            case "TEXTAREA":
              helper.CreateCmp(component, "lightning:formattedText", {
                value: datachunk.toString(),
                linkify: true
              });

              break;
            case "BOOLEAN":
              try {
                if (typeof datachunk === "boolean") {
                  helper.CreateCmp(component, "ui:outputCheckbox", {
                    value: datachunk
                  });
                }
              } catch (boolex) {
                helper.showError("Error parsing boolean");
              }
              break;

            case "EMAIL":
              helper.CreateCmp(component, "lightning:formattedEmail", {
                value: datachunk.toString()
              });

              break;
            case "PHONE":
              if (fieldstyle === "CTI") {
                helper.CreateCmp(component, "lightning:clickToDial", {
                  value: datachunk,
                  recordId: datachunkid
                });
              } else {
                helper.CreateCmp(component, "lightning:formattedPhone", {
                  value: datachunk
                });
              }

              break;
            case "URL":
              helper.renderHyperLink(component, datachunk, datachunk);
              break;

            default:
              //treat as text
              helper.CreateCmp("ui:outputText", { value: datachunk });

              break;
          }
        }
      }
    } catch (ex) {
      helper.showError("Error rendering");
      component.set("v.body", "Error: " + datachunk);
    }
  },

  NavigateToObj: function(component, event, helper) {
    var field = component.get("v.renderfield");
    var objID = field.datachunkid;
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: objID
    });
    navEvt.fire();
  },
  NavigateToURL: function(component, event, helper) {
    var field = component.get("v.renderfield");

    var url = event.getSource().get("v.value");
    var navEvt = $A.get("e.force:navigateToURL");
    navEvt.setParams({
      url: url
    });
    navEvt.fire();
  }
});
