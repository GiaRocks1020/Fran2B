({
 
	init : function(component, event, helper) {
		helper.fetchApplicants(component,helper);	
	},
    onAddOwner: function(component, event, helper) {
      component.set("v.editOwner.Id", "");
      helper.openModal(component,'Modalbox');
      component.set("v.isVisible", true);
    },
    onEditOwner: function(component, event, helper) {
      var owners = component.get("v.owners");
      var curIndex = event.currentTarget.dataset.index;
      component.set("v.editOwner",owners[curIndex]);
      helper.openModal(component,'Modalbox');
      component.set("v.isVisible", true);
    },

    onOwnerDeletion: function(component, event, helper) {
        var curIndex = event.currentTarget.dataset.index;
        component.set("v.curIndex",curIndex );
        helper.openModal(component,'Modalbox2');
    },

    handleDeleteOwner: function(component, event, helper) {
        var appRecord = component.get("v.newApplication");
        var owners = component.get("v.owners");
        var curIndex = component.get("v.curIndex");
        var owner = owners[curIndex];
    
        helper.removeOwner(component,helper, owner, curIndex);
    },

    handleCancelDeletion: function(component, event, helper) {
        helper.closeModal(component,'Modalbox2');
    },




    handleSave: function(component, event, helper) {
    
      var saveEvent = $A.get("e.c:ApplicationSave");
      saveEvent.setParams({"componentFired" : "Owners" });
      saveEvent.fire();
      
    },

    handleScrollUp:function(component,event,helper){
      var scrollingDiv = component.find('modalContent');
      scrollingDiv.getElement().scrollTop = 0;
    },

    handleCancel: function(component, event, helper) {
      helper.closeModal(component,'Modalbox');
      component.set("v.isVisible", false);
      helper.fetchApplicants(component);  
    },

    handleCloseModal:function(component, event, helper) {
      helper.closeModal(component,'Modalbox');
      component.set("v.isVisible", false);
      helper.fetchApplicants(component);  
    },


    
    
    runValidation : function(component, evt, helper){
        var owners = component.get("v.owners");
        helper.clearErrors(component);
        var nullError = false;
        var errors = false;
        var total = 0.00;
        
        if(owners.length == 0){
            component.set("v.showErrors", true);
        	component.set("v.showOwnerRequiredError", true);
            errors = true;
        }
        
        for(var i = 0; i < owners.length; i++){
            if(owners[i].Ownership__c != null){
                total += owners[i].Ownership__c;
            }
            if(owners[i].Ownership__c == null){
                nullError = true;
            }
        }
        
        if(total > 100.00){
            component.set("v.showErrors", true);
        	component.set("v.showOver100Error", true);
            errors = true;
        }
        
        if(nullError){
            component.set("v.showErrors", true);
        	component.set("v.showNullError", true);
            errors = true;
        }
        
        if(errors == false){
            helper.incrementStep(component);
        }
    },
    
    decrementStep : function(component, event, helper) {
        var step = component.get('v.step');
        if(step > 1){
        	component.set('v.step', step - 1);           
        }
    },


})