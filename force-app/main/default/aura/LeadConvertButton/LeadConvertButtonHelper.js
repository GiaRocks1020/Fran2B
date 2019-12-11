({
	fetchLead : function(cmp) {
		var action = cmp.get('c.getLeadById');
        action.setParams({leadId : cmp.get('v.recordId')});

        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var lead = response.getReturnValue();
                cmp.set('v.lead', lead);
                if(lead.isConverted == true){
                    cmp.set('v.showButton', false);
                }
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
                cmp.set('v.showButton', false);
            }
        }));
        $A.enqueueAction(action);
	}
})