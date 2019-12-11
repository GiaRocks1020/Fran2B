({

	setPAField : function(component,helper) {
        component.find("PA_or_LOI__c").set("v.value", true);

        var action = component.get("c.updatePAorLOI");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
        },
        
	setDeedField : function(component,helper) {
        component.find("Deed__c").set("v.value", true);

        var action = component.get("c.updateUploadDeed");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
        },


    
        
	setLeaseField : function(component,helper) {
        component.find("Lease_Agreement__c").set("v.value", true);

        var action = component.get("c.updateLeaseAgreement");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
	},

	showToast : function(component,helper,errorType,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "message": message
            });
        toastEvent.fire();
    },

    setCheckboxToFalse : function(component,event,helper){
        var uploadLocation = event.getParam("uploadLocation");
        component.find(uploadLocation).set("v.value", false);
       
    },

    setReciverBoolean : function(component){
        
        var bool = component.find("Is_this_hotel_in_Receivership__c").get("v.value");
        component.set("v.isReceivership", bool);
        debugger;
    },

    determineHiddenFields : function(component, fieldName, cmp, expectedValue){
        var value = component.find(fieldName).get("v.value")
        var cmpTarget = component.find(cmp);

        if(value != expectedValue){
            $A.util.addClass(cmpTarget, 'slds-hide');
        }
        else {
            try{
                $A.util.removeClass(cmpTarget, 'slds-hide');
            }
            catch (e){
                
            }
            
        }
    },
    
    clearFields : function(component, eventFields) {
            	
        if($A.util.hasClass(component.find("isReceivership"), "slds-hide")){
       		eventFields = this.clearRecievership(component, eventFields); 
        }
        
        if($A.util.hasClass(component.find("propWillNotBeLeased"), "slds-hide")){
        	eventFields = this.clearPropWillNotBeLeased(component, eventFields);
        }
        
        if($A.util.hasClass(component.find("propWillNotBePurchased"), "slds-hide")){
        	eventFields = this.clearPropWillNotBePurchased(component, eventFields);
        }
        
        if($A.util.hasClass(component.find("propWillBePurchased"), "slds-hide")){
        	eventFields = this.clearPropWillBePurchased(component, eventFields);
        }
        
        if($A.util.hasClass(component.find("propNotOwned"), "slds-hide")){
        	eventFields = this.clearPropNotOwned(component, eventFields);
        }
        
        if($A.util.hasClass(component.find("propOwned"), "slds-hide")){
        	eventFields = this.clearPropOwned(component, eventFields);
        }
        
        if($A.util.hasClass(component.find("bankOwned"), "slds-hide")){
        	eventFields = this.clearBankOwned(component, eventFields);
        }
        
        return eventFields;
	},
    
    clearRecievership : function(componentm, eventFields){
        eventFields["Receiver_Name__c"] = "";
        eventFields["Receivership_Phone__c"] = "";
        eventFields["Receivership_Address_Line_1__c"] = "";
        eventFields["Receivership_Address_Line_2__c"] = "";
        eventFields["Receivership_City__c"] = "";
        eventFields["Receivership_State_Province__c"] = "";
        eventFields["Receivership_Zip_Postal_Code__c"] = "";
        return eventFields;
    },
    
    clearPropWillNotBeLeased : function(component, eventFields){
        eventFields["Please_Explain__c"] = "";
        return eventFields;
    },
    
    clearPropWillNotBePurchased : function(component, eventFields){
        eventFields["Will_you_be_leasing_the_property__c"] = "";
        eventFields = this.clearPropWillNotBeLeased(component, eventFields);
        
        return eventFields;
    },
    
    clearPropWillBePurchased : function(component, eventFields){
        eventFields["What_is_the_expected_closing_date__c"] = "";
        
        return eventFields;
    },
    
    clearPropNotOwned : function(component, eventFields){
        eventFields["Are_you_purchasing_the_property__c"] = "";
        
        this.clearPropWillBePurchased(component, eventFields);
        this.clearPropWillNotBePurchased(component, eventFields);
        
        return eventFields;
	},
    
    clearPropOwned : function(component, eventFields){
        eventFields["Date_of_Ownership__c"] = "";
        eventFields["Property_currently_owned_by_a_lender__c"] = "";
        
        this.clearBankOwned(component, eventFields);
        
        return eventFields;
	},
    
    clearBankOwned : function(component, eventFields){
		eventFields["Lender_Name__c"] = "";
        eventFields["Lender_Phone__c"] = "";
        
        return eventFields;
    }
})