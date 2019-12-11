({    
    getInitialData : function(component,helper) {
        var app = component.get("v.app");
        var owner = component.get("v.owner");

        debugger;

		var action = component.get("c.handleDataInit");
        action.setParams({
            "appId": app.Id,
            "ownerId": owner.Id
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var envelope = JSON.parse(response.getReturnValue());
				component.set("v.owner", envelope.owner);
                component.set("v.idToPrivateFile", envelope.idToPrivateFile);
                
            }
            else {
                alert("There was an error creating a new owner");
            }
        });
        $A.enqueueAction(action);	
	},

    



    setStatementField:function  (component,helper){
        

        var action = component.get("c.updateFinancialStatement");

        action.setParams({"ownerId" : component.get("v.owner.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.find("Personal_Financial_Statement__c").set("v.value", true);
            } else {
                var errors = response.getError();
                var failedFields = Object.keys(errors[0].fieldErrors);
                var errorOutput = 'The following fields failed validation rules. ';
                for(var x = 0; x<failedFields.length; x++){
                    errorOutput += failedFields[x] + ' . ';
                }

                helper.showToast(component,helper,'other',errorOutput);

            }
        });
        $A.enqueueAction(action);
    },

    setResumeField:function  (component,helper){
        

        var action = component.get("c.updateOwnerResume");

        action.setParams({"ownerId" : component.get("v.owner.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.find("Owner_Resume__c").set("v.value", true);
            } else {
                var errors = response.getError();
                var failedFields = Object.keys(errors[0].fieldErrors);
                var errorOutput = 'The following fields failed validation rules. ';
                for(var x = 0; x<failedFields.length; x++){
                    errorOutput += failedFields[x] + ' . ';
                }

                helper.showToast(component,helper,'other',errorOutput);

            }
        });
        $A.enqueueAction(action);
    },

    setCheckboxToFalse : function(component,event,helper){
        var uploadLocation = event.getParam("uploadLocation");
        component.find(uploadLocation).set("v.value", false);
        
    },

    showToast:function(component,helper,errorType,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "message": message,
                mode: 'sticky'
            });
        toastEvent.fire();
    },

    scrollUp:function(component,helper){
        var scrollEvent = $A.get("e.c:ApplicationScrollUp");
        scrollEvent.fire();
    },

    closeModal:function(component,helper){
        var modalEvent = $A.get("e.c:ApplicationCloseModal");
        modalEvent.fire();
    },


})