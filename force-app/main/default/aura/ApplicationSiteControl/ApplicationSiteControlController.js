({
	init : function(component, event, helper) {
        
	},
    
    removeSpinner : function(component, event, helper) {
        component.set("v.showSpinner", false);
        helper.setReciverBoolean(component);
        component.find("section").set("v.value", "Site Control Information");

        helper.determineHiddenFields(component, "Is_this_hotel_in_Receivership__c", "isReceivership","Yes");
        helper.determineHiddenFields(component, "Do_you_own_the_property__c", "propOwned","Yes");
        helper.determineHiddenFields(component, "Do_you_own_the_property__c", "propNotOwned","No");
        helper.determineHiddenFields(component, "Property_currently_owned_by_a_lender__c", "bankOwned","Yes");
        helper.determineHiddenFields(component, "Are_you_purchasing_the_property__c", "propWillBePurchased","Yes");
        helper.determineHiddenFields(component, "Are_you_purchasing_the_property__c", "propWillNotBePurchased","No");
        helper.determineHiddenFields(component, "Will_you_be_leasing_the_property__c", "propWillBeLeased","Yes");
        helper.determineHiddenFields(component, "Will_you_be_leasing_the_property__c", "propWillNotBeLeased","No");

    },

    handleFileDeletion:function(component, event, helper) {
        helper.setCheckboxToFalse(component,event,helper);
        
    },
    handleFileUpload : function(component, event, helper){
        var section = event.getSource().get("v.section");
        if(section == 'Deed__c'){
            helper.setDeedField(component,helper);
        } else if(section == 'PA_or_LOI__c'){
            helper.setPAField(component,helper);
        }else if(section == 'Lease_Agreement__c'){
            helper.setLeaseField(component,helper);
        }
    },

    
    
    handleRendering : function(component, event, helper) {
    	var id = event.getSource().getLocalId();
        var pickListValue = component.find(id).get("v.value");
        if(id == "Do_you_own_the_property__c"){
            component.set("v.newApplication.Do_you_own_the_property__c", pickListValue);
            //if null or no hide propOwned, clear section 1,3,4
            helper.determineHiddenFields(component, id, "propOwned","Yes");

            //if yes or null hide PropNotOwned, clear section 2,5,6,7,8
            helper.determineHiddenFields(component, id, "propNotOwned","No");
            
            component.set("v.newApplication.Do_you_own_the_property__c", pickListValue);
        }
        
        if(id == "Property_currently_owned_by_a_lender__c"){
            //if null or no hide bankOwned
            helper.determineHiddenFields(component, id, "bankOwned","Yes");
            component.set("v.newApplication.Property_currently_owned_by_a_lender__c", pickListValue);
        }
        
        if(id == "Are_you_purchasing_the_property__c"){
            //if null or no, hide propWillBePurchased, clear 5
           	helper.determineHiddenFields(component, id, "propWillBePurchased","Yes");
            //
            //if null or yes, hide propWillNotBePurchased
            helper.determineHiddenFields(component, id, "propWillNotBePurchased","No");
            
            component.set("v.newApplication.Are_you_purchasing_the_property__c", pickListValue);
        }
        
        if(id == "Will_you_be_leasing_the_property__c"){
            //if null or no, hide propWillBeLeased, clear 8
            helper.determineHiddenFields(component, id, "propWillBeLeased","Yes");
            //
            //if null or yes, hide propWillNotBeLeased
            helper.determineHiddenFields(component, id, "propWillNotBeLeased","No");
            
            component.set("v.newApplication.Will_you_be_leasing_the_property__c", pickListValue);
        }

        if(id == "Is_this_hotel_in_Receivership__c"){
            helper.determineHiddenFields(component, id, "isReceivership","Yes");
        }
    },
    
    incrementStep : function(component) {
		scroll(0,0);
		var step = component.get('v.step');
        component.set('v.step', step + 1);
	},
    
    decrementStep : function(component, event, helper) {
        var step = component.get('v.step');
        if(step > 1){
        	component.set('v.step', step - 1);         
        }
    },

    
   

    onError : function(component, event, helper) {
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        scroll(0,80);
    },

    setSection : function(component, event, helper) {
        event.preventDefault();
        component.find("section").set("v.value", "Site Control Information");
        var eventFields = event.getParam("fields");

        eventFields = helper.clearFields(component, eventFields);
        //console.log(JSON.stringify(eventFields));
        component.find("editForm").submit(eventFields);
    }
})