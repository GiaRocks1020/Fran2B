({
    init : function(component, event, helper) {
        helper.fetchLead(component);
	},
	navigateLeadConversionComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LeadConversionComponent",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
	}    
})