({
	fetchLead : function(cmp) {
		var action = cmp.get('c.getLeadById');
        action.setParams({leadId : cmp.get('v.recordId')});

        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.lead', response.getReturnValue());
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
	}
})