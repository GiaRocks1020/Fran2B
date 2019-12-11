({
	init : function(component, event, helper) {
       
        helper.getInitialData(component,helper);

        component.find("section").set("v.value", "Ownership");
	},


    onRecordLoad:function(component, event, helper) {
       
        component.set("v.showSpinner", false);
        component.find("section").set("v.value", "Ownership");
         helper.scrollUp(component,helper);
        
    },

    handleSaveEvent:function(component, event, helper) {
        if(event.getParam("componentFired") == "Owners"){
            component.find("editForm").submit();  
        }
    },



    onSubmitSuccess:function(component, event, helper) {
        helper.closeModal(component,helper);
    },

    

    handleFileUpload : function(component, event, helper){
        var section = event.getSource().get("v.section");
        if(section == 'Owner_Resume__c'){
            helper.setResumeField(component,helper);
        }else if(section == 'Personal_Financial_Statement__c'){
            helper.setStatementField(component,helper);
        }
    },
    
    
    onError : function(component,event, helper) {
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        helper.scrollUp(component,helper);
    },

    handleMouseOver: function(component,event, helper) {
        var id = event.getSource().getLocalId() + 'Help';
        var cmpTarget = component.find(id);
        $A.util.removeClass(cmpTarget, 'slds-hide');

    },

     handleMouseOut: function(component,event, helper) {

        var id = event.getSource().getLocalId() + 'Help';
        var cmpTarget = component.find(id);
        $A.util.addClass(cmpTarget, 'slds-hide');

    },



})