({
	fetchPicklistValues : function(component, object, field, attributeToUpdate) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objObject": object,
            "fld": field
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var types = component.get("v.applicationTypes");
                component.set(attributeToUpdate, response.getReturnValue());
                console.log(component.get(attributeToUpdate));
            }
        });
        $A.enqueueAction(action);		
	},

    setCheckboxToFalse : function(component,event,helper){
        var uploadLocation = event.getParam("uploadLocation");
        component.find(uploadLocation).set("v.value", false);
    },
    
    clearFields : function(component, buttonName){
        debugger;
        var app = component.get("v.newApplication");
		
        if(buttonName === "removeBank"){
            app.Name_of_Bank_2__c = null;
            app.Information_Bank_2_Contact__c = null;
            app.Information_Bank_2_Address_Line_1__c = null;
            app.Information_Bank_2_Address_Line_2__c = null;
            app.Information_Bank_2_City__c = null;
            app.Information_Bank_2_State_Province__c = null;
            app.Information_Bank_2_Country__c = null;
            app.Information_Bank_2_Zip_Postal_Code__c = null;
            app.Information_Bank_2_Phone__c = null;
            app.Information_Bank_2_Account_In_Name_of__c = null;
            app.Information_Bank_2_Account__c = null;
            app.Checking_Account_2__c = false;
            app.Savings_Account_2__c = false;
            app.Loan_Account_2__c = false;            
        }
        
        if(buttonName === "removeBusiness"){
            app.Information_Business_2_Company_Name__c
            app.Information_Business_2_Contact__c = null;
            app.Information_Business_2_Address_Line_1__c = null;
            app.Information_Business_2_Address_Line_2__c = null;
            app.Information_Business_2_City__c = null;
            app.Information_Business_2_State_Province__c = null;
            app.Information_Business_2_Country__c = null;
            app.Information_Business_2_Zip_Postal_Code__c = null;
            app.Information_2_Business_Phone__c = null;
            app.Information_Business_2_Account_In_Name_of__c = null;
            app.Information_Business_2_Account__c = null;
        }
        component.set("v.newApplication", app);
    },
    
    incrementStep : function(component) {
        debugger;
		scroll(0,0);
		var step = component.get('v.step');
        component.set('v.step', step + 1);
	},

    submitEditForm:function(component,helper){
        component.find("editForm").submit();
    },

    handleShowModal: function(component, helper) {
        var modalBody;
        var modalFooter;
        var newApplication = component.get("v.newApplication");
        var applications = component.get("v.applications");


        $A.createComponents([
            ["c:ApplicationSubmission",{"newApplication":newApplication, "applications":applications}],
            ["c:ApplicationSubmissionFooter",{}]
        ],
        function(components, status){
            if (status === "SUCCESS") {
                modalBody = components[0];
                modalFooter = components[1];
                component.find('overlayLib').showCustomModal({
                   header: "Application Confirmation",
                   body: modalBody, 
                   footer: modalFooter,
                   showCloseButton: true,
                   cssClass: "my-modal,my-custom-class,my-other-class",
                   closeCallback: function() {
                       
                   }
               })
            }
        }
       );
    },

     setADAField:function(component,helper){
        component.find("ADA_Certificate__c").set("v.value", true);

        var action = component.get("c.updateADACertificate");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

     setInsuranceField:function(component,helper){
        component.find("Insurance_Certificate__c").set("v.value", true);

        var action = component.get("c.updateInsuranceCertificate");

        action.setParams({"appId" : component.get("v.newApplication.Id")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {

            } else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
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