({
	getInitialData : function(component,helper) {

		var action = component.get("c.getDataEnvelope");

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	var envelope = JSON.parse(response.getReturnValue());
            	component.set("v.applications", envelope.applications);
                
            } else {
                var errors = response.getError();
                
            }
        });
        $A.enqueueAction(action);
		
	},
})