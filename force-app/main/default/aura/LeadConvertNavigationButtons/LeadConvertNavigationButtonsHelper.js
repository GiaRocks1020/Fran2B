({
	hideModal : function(cmp){    
       var cmpTarget = cmp.find('Modalbox');
       var cmpBack = cmp.find('Modalbackdrop');
       $A.util.removeClass(cmpBack,'slds-backdrop--open');
       $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
   },
    
    showModal : function(cmp){
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    callLeadConversion : function(cmp){
        var step = cmp.get('v.screen');
        var lead = cmp.get('v.lead');
        var contactId = cmp.get('v.contact.Id');
        var accountId = cmp.get('v.account.Id');
        
        var action;
        if(step == 2){
            action = cmp.get('c.leadConversionStep2');
            action.setParams({lead : lead, contactId : contactId, accountId : accountId});            
        }
        debugger;
        if(step == 3){
            var propertyId = cmp.get('v.property.Id');
            var createDeal = cmp.get('v.createDeal');
			action = cmp.get('c.leadConversionStep3');
            action.setParams({lead : lead, contactId : contactId, accountId : accountId, propertyId : propertyId, createDeal : createDeal});
        }

        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            console.log(response.getReturnValue())
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                cmp.set('v.errorList', results);
                if(results.length == 1){
                	this.redirectToObject(results[0]);
                }
                else{
                    this.showModal(cmp);  
                }
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    redirectToObject : function(objectId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": objectId,
        });
        navEvt.fire();    
	}
})