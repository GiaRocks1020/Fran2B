({  
    fetchLegalRepInfo : function(component) {
        var action = component.get("c.getLegalRepInfo");
        action.setParams({
            "id": component.get("v.newApplication.Id")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().length != 0){
                    console.log("before legalRep Set");
                    component.set("v.legalRep", response.getReturnValue()[0]);
                     console.log("after legalRep Set");
                }
                else{
                   this.createRep(component);
                }
                
            }
           
        });
        $A.enqueueAction(action);		
	},
    
    createRep : function(component) {
        var action = component.get("c.createLegalRep");
        action.setParams({
            "id": component.get("v.newApplication.Id")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rep = response.getReturnValue();
                
                component.set("v.legalRep", rep);
                component.set("v.legalRep.Salutation__c", rep.Salutation__c);
            }
        });
        $A.enqueueAction(action);		
	},

    deleteTest:function(component,helper){
        var eventFields = {};
        eventFields["Entity_Document__c"] = false;


        component.find("editForm2").submit(eventFields);
    },



    
     removeSpinner : function(component, helper) {
        component.set("v.showSpinner", false);
        component.find("section").set("v.value", "Designated Representative");
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