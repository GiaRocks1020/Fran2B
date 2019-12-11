({
	getEnvelope : function(component,helper) {

		var action = component.get("c.getDataEnvelope");
        var propId = component.get("v.recordId");
      
        action.setParams({ 
            propId: propId
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	var envelope = JSON.parse(response.getReturnValue());
            	var code =envelope.propMtd;

            	component.set("v.property", envelope.property);
            	component.set("v.latestGeneratedCode", code);
            	component.set("v.propertyCodeMap", envelope.propertyCodeMap);
        
                helper.showOrHideSpinner(component,false);
         
                component.set("v.displayedCode", code.Identifier_Code__c);
            	
                if(!code.State_Country_Code__c){
                    helper.disableAll(component,helper);
                    helper.displayError(component,$A.get("$Label.c.Business_Not_Established"));
                }
            }
            else{
                helper.showOrHideSpinner(component,false);
                helper.disableAll(component,helper);
                helper.displayError(component,"There was an error upon loading. " + 
                    " Please contact your administrator for assistance.");
            }

        });
        $A.enqueueAction(action);
	},


	getNextCode : function(component,helper) {

		var action = component.get("c.incramentCode");
        var currentCode = component.get("v.latestGeneratedCode.Identifier_Code__c");
        var prefixLetters = component.get("v.latestGeneratedCode.State_Country_Code__c");
      	var propertyCodeMap = component.get("v.propertyCodeMap");
        action.setParams({ 
            "currentCode": currentCode,
            "propertyCodeMap": propertyCodeMap,
            "prefixLetters": prefixLetters
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	var newCode = response.getReturnValue();
            	var latestGeneratedCode = component.get("v.latestGeneratedCode");
            	latestGeneratedCode.Identifier_Code__c = newCode;

            	component.set("v.displayedCode",newCode);
            	component.set("v.latestGeneratedCode",latestGeneratedCode);
            	component.set("v.property.Property_Code__c",helper.createPropertyCode(component));

            	helper.showOrHideSpinner(component,false);
            }

        });
        $A.enqueueAction(action);
	},


	saveManualCode:function(component,helper) {
		var action = component.get("c.saveManualCode");
        var property = component.get("v.property");
		property= JSON.stringify(property);

		action.setParams({ 
            "propertyJson": property
  
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	helper.showToast(component,helper,"other", "You have successfully accepted the property code.");
            	helper.showOrHideSpinner(component,false);
                var closeModal = $A.get("e.c:ApplicationCloseModal");
                closeModal.fire();
            }
            else{
            	if(response.error["0"].pageErrors["0"].statusCode == 'DUPLICATE_VALUE'){
                    helper.displayError(component,$A.get("$Label.c.Property_Code_Taken"));
            	}
            	helper.showOrHideSpinner(component,false);
            }
        });
        $A.enqueueAction(action);
	},

	saveAutoCode:function(component,helper) {
		var action = component.get("c.saveAutoGenCode");
        var latestGeneratedCode = component.get("v.latestGeneratedCode");
        var property = component.get("v.property");

		property= JSON.stringify(property);
		latestGeneratedCode= JSON.stringify(latestGeneratedCode);

		action.setParams({ 
            "propertyJson": property,
            "propMtdJson":latestGeneratedCode
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
            	helper.showToast(component,helper,"other", "You have successfully accepted the property code.");
            	helper.showOrHideSpinner(component,false);
            	var closeModal = $A.get("e.c:ApplicationCloseModal");
                closeModal.fire();
            }
            else{
            	if(response.error["0"].pageErrors["0"].statusCode == 'DUPLICATE_VALUE'){
					helper.displayError(component,$A.get("$Label.c.Property_Code_Taken"));
            	}
            	helper.showOrHideSpinner(component,false);
            }
        });
        $A.enqueueAction(action);

	},


	checkIfManual:function(component, helper){
		var displayedCode = component.get("v.displayedCode");
		var latestGeneratedCode = component.get("v.latestGeneratedCode");

		if(displayedCode != latestGeneratedCode.Identifier_Code__c){
			component.set("v.manualChange" , "true");
			component.set("v.property.Property_Code__c",helper.createPropertyCode(component));
			component.find("generateCode").set("v.disabled", "true");

		}

	},

	checkIfCodeTaken:function(component,helper){
		var currentCode = helper.createPropertyCode(component);
		var propertyCodeMap = component.get("v.propertyCodeMap");
		if(propertyCodeMap[currentCode]){
			helper.displayError(component,$A.get("$Label.c.Property_Code_Taken"));
            helper.toggleButton(component,"acceptCode", "true");
		}
		else{
            helper.hideError(component);
            helper.toggleButton(component,"acceptCode", "false");
		}
		
	},

    validate:function(component,helper){
        var displayedCode = component.get("v.displayedCode");
        var regex = /[A-Z0-9]/g;
        if(displayedCode.match(regex) != null && displayedCode.match(regex).length == 3){
            return true;
        }
        return false;
    },

	createPropertyCode:function(component){
		var latestGeneratedCode = component.get("v.latestGeneratedCode");
		var displayedCode = component.get("v.displayedCode");
		return latestGeneratedCode.State_Country_Code__c +displayedCode;
	},

    toggleButton:function (component, auraId, disabled){
        component.find(auraId).set("v.disabled", disabled);
    },

	showOrHideSpinner:function(component, toShow ){
        if(!toShow){
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.showSpinner",toShow);
                }), 1000
            );

        }else{
            component.set("v.showSpinner",toShow);
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

    displayError:function(component,messasge){
    	component.set("v.errorMessage", messasge);
		var cmpTarget = component.find('errorMessage');
		$A.util.removeClass(cmpTarget, 'slds-hide');
    },

    hideError:function(component){
        var cmpTarget = component.find('errorMessage');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },


    disableAll:function(component,helper){
        helper.toggleButton(component,"acceptCode", "true");
        helper.toggleButton(component,"generateCode", "true");
        helper.toggleButton(component,"displayedCode", "true");
    },
})