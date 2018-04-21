({
  GetRecordTypes: function(component, sobjectname) {
    var action = component.get("c.GetRecordTypes");
    action.setParams({
      sObjectTypeParam: sobjectname
    });
    action.setAbortable();

    //Set up the callback
    var self = this;
    action.setCallback(this, function(actionResult) {
      if (actionResult.getState() === "SUCCESS") {
        var results = JSON.parse(actionResult.getReturnValue());

        if (results.length > 1) {
          component.set("v.Options", results);
          $A.util.removeClass(component.find("createdialog"), "slds-hide");
        } else {
          $A.util.addClass(component.find("createdialog"), "slds-hide");
          this.doCreate(component);
        }
      }
    });

    $A.enqueueAction(action);
  },
  doCreate: function(component) {
    var rtid = component.get("v.rtid");
    var objecttype = component.get("v.sObjectType");
    var navEvt = $A.get("e.force:createRecord");
    navEvt.setParams({
      entityApiName: objecttype,
      recordTypeId: rtid
    });

    $A.util.addClass(component.find("createdialog"), "slds-hide");
    navEvt.fire();
  },
  showToast: function(msg) {
    var navToast = $A.get("e.force:showToast");
    navToast.setParams({
      title: "",
      message: msg
    });
    navToast.fire();
  },
  doDelete: function(component, sObjectID) {
    var action = component.get("c.DeleteObject");
    action.setParams({
      ObjectID: sObjectID
    });
    action.setAbortable();

    //Set up the callback
    var self = this;
    action.setCallback(this, function(actionResult) {
      if (actionResult.getState() === "SUCCESS") {
        var results = JSON.parse(actionResult.getReturnValue());

        if (results.isError === true) {
          self.showToast(results.message);
        } else {
          self.showToast("Successfully deleted record");

          var evtRefresh = $A.get("e.c:evtRefreshSDG");
          evtRefresh.fire();
        }
      }
    });

    $A.enqueueAction(action);
  }
});
