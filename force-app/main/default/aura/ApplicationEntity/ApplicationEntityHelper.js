({
    toggleEntityFields : function(component) {
        
        var cmpTarget = component.find('entityInfoWrapper');
        var type = component.find('entityType').get("v.value");
        var fieldshidden = component.get("v.hideFields");
        var selection = component.get("v.entitySelections");


        if(type == "To be formed" || type == "" || type == null || fieldshidden == true || selection =='Individual'){
            $A.util.addClass(cmpTarget, 'slds-hide');
            component.set("v.hideFields", true);           
        }
        else{
           $A.util.removeClass(cmpTarget, 'slds-hide');
            component.set("v.hideFields", false);
        }
    },

    updateCheckboxFields:function(component){
        var sectionToUpdateMap = component.get("v.sectionToUpdateMap");
    },

    
     removeEntityTypeFieldsOnSubmit : function(component,helper,eventFields){

        if(eventFields["Applying_as_an_Individual_or_Entity__c"] == "Individual" || eventFields["Applying_as_an_Individual_or_Entity__c"] == null){
            eventFields["Entity_Type__c"] = "";
        }

        eventFields["Country_Formed__c"] = "";
        eventFields["EIN__c"] = "";
        eventFields["Entity_Address_Line_1__c"] = "";
        eventFields["Entity_Address_Line_2__c"] = "";
        eventFields["Entity_City__c"] = "";
        eventFields["Entity_Country__c"] = "";
        eventFields["Entity_Document__c"] = false;
        eventFields["Entity_Name__c"] = "";
        eventFields["Entity_State_Province__c"] = "";
        eventFields["Entity_Zip_Postal_Code__c"] = "";
        eventFields["State_Formed__c"] = "";
        if(eventFields["Entity_Type__c"] != "To be formed"){
            eventFields["Entity_Type__c"] = "";
        }
        return eventFields;
     },

    setEntityField:function(component,helper){
        
        var action = component.get("c.updateEntityDocuments");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.find("Entity_Document__c").set("v.value", true);
            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

    hideFieldsOnLoad:function(component,helper){
         var cmpTarget = component.find('entityWrapper');
        var selection = component.get("v.entitySelections");
        
        if(selection != "Entity"){
            $A.util.addClass(cmpTarget, 'slds-hide');
            component.set("v.hideFields", true);
        }

    },

    checkCountryFields:function(component,helper){
        var newApplication = component.get("v.newApplication");
        if(newApplication.Country_Formed__c == null || newApplication.Country_Formed__c == ''){
            newApplication.Country_Formed__c = 'US';
        }

         if(newApplication.Entity_Country__c == null || newApplication.Entity_Country__c == ''){
            newApplication.Entity_Country__c = 'US';
        }
        component.set("v.newApplication",newApplication);
        
    },

    shouldClearFields:function(component,helper){
        var entityType =  component.find("entityType").get("v.value");
        var applyingType =  component.find("applyingType").get("v.value");

        if(applyingType == 'Individual' || entityType == 'To be formed'){
            return true;
        }
        else{
            return false;
        }

    },

    showToast:function(component,helper,errorType,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "message": message
            });
        toastEvent.fire();
    },


})