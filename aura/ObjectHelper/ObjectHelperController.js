({
  handleevtObjectManager: function(component, event, helper) {
    var params = event.getParam("arguments").Payload;
    var action = params.Action.toLowerCase();
    component.set("v.CoreEvent", params);

    if (action === "create") {
      component.set("v.sObjectType", params.sObjectType);
      //Now get data on the record types:
      helper.GetRecordTypes(component, params.sObjectType);
    }

    if (action === "delete") {
      $A.util.removeClass(component.find("deletedialog"), "slds-hide");
    }
  },

  cancel: function(component, event, helper) {
    $A.util.addClass(component.find("createdialog"), "slds-hide");
    $A.util.addClass(component.find("deletedialog"), "slds-hide");
  },
  handledelete: function(component, event, helper) {
    var coreevent = component.get("v.CoreEvent");

    helper.doDelete(component, coreevent.sObjectID);

    $A.util.addClass(component.find("deletedialog"), "slds-hide");
  },
  setRecordTypeID: function(component, event, helper) {
    var label = event.getSource().get("v.text");
    var rts = component.get("v.Options");
    var rtid;

    for (var rtkey in rts) {
      var rt = rts[rtkey];
      if (rt.Name === label) {
        rtid = rt.Value;
      }
    }
    component.set("v.rtid", rtid);
  },

  create: function(component, event, helper) {
    helper.doCreate(component);
  }
});
