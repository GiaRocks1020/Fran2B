({
	goToNextScreen : function(component, event, helper) {
        component.set('v.screen', component.get('v.screen')+1);
	},
    
	goToPreviousScreen : function(component, event, helper) {
		component.set('v.screen', component.get('v.screen')-1);
	},
    
    handleShowModal: function(component, evt, helper) {
		helper.showModal(component);
    },
    
	closeModal : function(component, evt, helper){
		helper.hideModal(component);
   },
    
	redirect : function(component, evt, helper){
        helper.hideModal(component);
        var navEvt = $A.get("e.force:navigateToSObject");
        var leadId = component.get('v.lead.Id');
        navEvt.setParams({
          "recordId": leadId,
        });
        navEvt.fire();

   },
    
    convertLead : function(component, evt, helper){
    	helper.callLeadConversion(component);
	},
})