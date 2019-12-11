({
	getData:function(component, helper) {
		var action = component.get("c.checkPermission");
      	var propId = component.get("v.recordId"); 
      	action.setParams({ 
            "propertyId": propId
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	var hasPermission = response.getReturnValue();
            	component.set("v.toShow", hasPermission);
            }

        });
        $A.enqueueAction(action);
	},
	openModal : function(component) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        component.set("v.isVisible", true);

    },
    closeModal : function(component){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.isVisible", false);
    },
})