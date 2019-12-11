({
	setFirstTimeData:function (component, helper) {
        var action = component.get("c.handleFirstTime");

        action.setParams({appString : JSON.stringify(component.get("v.newApplication"))});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var idToPrivateFiles =  response.getReturnValue();
                component.set("v.idToPrivateFiles", idToPrivateFiles);

                helper.setUploadIds(component,helper,idToPrivateFiles);

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    }, 


    fetchPrivateFiles:function (component, helper) {
        var action = component.get("c.getPrivateFiles");

        action.setParams({appString : JSON.stringify(component.get("v.newApplication"))});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var idToPrivateFiles =  response.getReturnValue();
                component.set("v.idToPrivateFiles", idToPrivateFiles);
                helper.setUploadIds(component,helper,idToPrivateFiles);

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    }, 



	removeSpinner : function(component, event, helper) {
        component.set("v.showSpinner", false);
        $A.enqueueAction(component.get("c.showPropertyCode"));
        component.find("section").set("v.value", "Hotel Information");
    },

     incrementStep : function(component,helper) {
        scroll(0,0);
        var step = component.get('v.step');
        component.set('v.step', step + 1);
    },

    showToast:function(component,helper,errorType,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "message": message
            });
        toastEvent.fire();
    },
})