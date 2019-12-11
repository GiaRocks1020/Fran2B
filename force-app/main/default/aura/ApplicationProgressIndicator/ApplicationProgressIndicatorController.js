({
	init: function(component, event, helper) {
		jQuery("document").ready(function(){


	 	 });
	
	},

    updateStep : function(component, event, helper) {
    	component.set('v.step', component.get('v.currentStep').toString());
    },
})