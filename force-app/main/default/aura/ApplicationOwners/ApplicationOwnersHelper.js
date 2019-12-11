({
	fetchApplicants : function(component,helper) {
        component.set("v.showSpinner", true);
		var action = component.get("c.getApplicantsRelatedToApp");

        action.setParams({
            "appId":component.get("v.newApplication.Id")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.owners", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else{
                helper.showToast(component,helper,'other','There was an error retrieving owners.');
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
	},
    
    removeOwner : function(component,helper, owner, index) {
		var action = component.get("c.deleteOwner");
        action.setParams({
            "owner": owner
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.owners", response.getReturnValue());
                var owners = component.get("v.owners");
                helper.closeModal(component,'Modalbox2');
                owners.splice(index, 1);
                component.set("v.owners", owners);
                
            }
            else{
                helper.showToast(component,helper,"other", "There was an error deleting the owner");
            }
        });
        $A.enqueueAction(action);
	},

    
    
    clearErrors : function(component){
        component.set("v.showErrors", false);
        component.set("v.showOver100Error", false);
        component.set("v.showNullError", false);
        component.set("v.showOwnerRequiredError", false);
    },
    
    incrementStep : function(component) {
		scroll(0,0);
		var step = component.get('v.step');
        component.set('v.step', step + 1);
    },

    closeModal : function(component,modalName){    
        var cmpTarget = component.find(modalName);
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
    },

    openModal : function(component,modalName) {
        var cmpTarget = component.find(modalName);
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        

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