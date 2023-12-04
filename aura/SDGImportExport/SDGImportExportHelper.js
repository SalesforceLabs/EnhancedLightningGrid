({
    export: function (component) {
        var action = component.get("c.ExportSDG");
        var params = {
            "Id": component.get("v.recordId")
        };
        action.setParams(params);
        action.setAbortable();

        action.setCallback(this, function (actionResult) {

            if (actionResult.getState() == 'SUCCESS') {
                var results = actionResult.getReturnValue();

                if (results != null) {
                    component.set("v.payload", results);

                }
            }
            else {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast('error', errors[0].message)
                    }
                }
            }

        });


        $A.enqueueAction(action);
    },
    import: function (component) {

        var action = component.get("c.ImportSDG");
        var params = {
            "payload": component.get("v.importpayload")
        };
        action.setParams(params);
        action.setAbortable();

        action.setCallback(this, function (actionResult) {

            if (actionResult.getState() == 'SUCCESS') {
                var results = actionResult.getReturnValue();

                if (results != null) {
                    this.showToast('success', 'Record saved');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": results
                    });
                    navEvt.fire();

                }
            }
            else {

                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //this.showToast('error', errors[0].message, 'sticky');
                        component.set('v.Error', errors[0].message);
                    }
                }
            }

        });

        $A.enqueueAction(action);
    },

    showToast: function (type, message) {

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})