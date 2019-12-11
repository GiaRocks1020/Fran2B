({   
    onload : function(component, event, helper) {
        component.set("v.showSpinner", false);
        component.find("section").set("v.value", "Franchising & Hotel Experience");
        helper.setUploadIds(component,helper);
    },
    
    decrementStep : function(component, event, helper) {
        var step = component.get('v.step');
        if(step > 1){
        	component.set('v.step', step - 1);           
        }
    },
    
    incrementStep : function(component) {
		scroll(0,0);
		var step = component.get('v.step');
        component.set('v.step', step + 1);
	},

    onError : function(component,event, helper) {
        //var errorMessage = event._params.error.data.output.errors["0"].message;
        helper.showToast(component,helper,'other','20000', 'Please review the errors on the page.');
        scroll(0,80);
    },

    handleMouseOver: function(component,event, helper) {
        //event.getSource().getLocalId(); gets aura id
        var id = event.getSource().getLocalId() + 'Help';
        var cmpTarget = component.find(id);
        $A.util.removeClass(cmpTarget, 'slds-hide');

    },

     handleMouseOut: function(component,event, helper) {

        var id = event.getSource().getLocalId() + 'Help';
        var cmpTarget = component.find(id);
        $A.util.addClass(cmpTarget, 'slds-hide');

    },
})