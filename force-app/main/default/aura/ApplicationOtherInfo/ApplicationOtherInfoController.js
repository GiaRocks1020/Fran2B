({
	init : function(component, event, helper) {
	},
    
    addExtraEntries : function(component, event, helper){
        var buttonName = event.getSource().get("v.name");
        if(buttonName === "addBank"){
			component.set("v.showBank2", true);            
        }
        if(buttonName === "addBusiness"){
			component.set("v.showBusiness2", true);            
        }
    },
    
    removeExtraEntries : function(component, event, helper){
        var app = component.get("v.newApplication");
        var buttonName = event.getSource().get("v.name");

        if(buttonName === "removeBank"){
			component.set("v.showBank2", false);            
        }

        if(buttonName === "removeBusiness"){
			component.set("v.showBusiness2", false);            
        }
        
        helper.clearFields(component, buttonName);
    },

	handleFileUpload : function(component, event, helper){
        var section = event.getSource().get("v.section");
        if(section == 'ADA_Certificate__c'){
            //helper.setADAField(component,helper);
            component.find("ADA_Certificate__c").set("v.value", true);
        }
        else if(section == 'Insurance_Certificate__c'){
            //helper.setInsuranceField(component,helper);
            component.find("Insurance_Certificate__c").set("v.value", true);
        }
    },

   

    handleFileDeletion:function(component, event, helper) {
        helper.setCheckboxToFalse(component,event,helper);
    },

    onSubmit:function(component,event,helper){

        helper.handleShowModal(component,helper);
        helper.submitEditForm(component,helper);
        //helper.incrementStep(component);

    },
    
    validateFields : function(component, event, helper) {
        //var rooms = component.find("numOfRooms");
        //var error = component.find("errorMessage");
        //debugger;
        //$A.util.addClass(rooms,'slds-has-error');
        //$A.util.removeClass(error,'slds-hide');
        //rooms.setErrors(["Enter some text"]);
        //rooms.set("v.errorComponent", [{message:"Enter some text"}]);
        //var x = document.getElementsByClassName("slds-has-error");
        //var isExpandable = $A.util.hasClass(rooms, "slds-has-error");
        //lert(x.length);
        
        //component.find("editForm").submit();
        //debugger;
        //helper.incrementStep(component);
    },

	removeSpinner : function(component, event, helper) {
        component.set("v.showSpinner", false);
        component.find("section").set("v.value", "Financial and Insurance Information");
    },

	decrementStep : function(component, event, helper) {
        var step = component.get('v.step');
        if(step > 1){
        	component.set('v.step', step - 1);           
        }
    },

    

    onError : function(component,event, helper) {
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        scroll(0,80);
    },



})