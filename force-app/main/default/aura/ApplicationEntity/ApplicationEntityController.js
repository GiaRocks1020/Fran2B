({
	init : function(component, event, helper) {

       

	},


  

    onRecordLoad:function(component,event,helper){
        var isFirstTime = component.get("v.isFirstTime");
        if(isFirstTime){
            component.set("v.isFirstTime", false);
            component.set("v.showSpinner", false);

            helper.checkCountryFields(component,helper);
            helper.toggleEntityFields(component);
            component.find("section").set("v.value", "Entity Information");
            helper.hideFieldsOnLoad(component,helper);
        }
        
    },

	handleFileUpload : function(component, event, helper){
        var section = event.getSource().get("v.section");
        if(section == 'Entity_Document__c'){
            helper.setEntityField(component,helper);
        }
	},
      handleFileDeletion:function(component, event, helper) {
        var uploadLocation = event.getParam("uploadLocation");
        if(uploadLocation == 'Entity_Document__c'){
            component.find("Entity_Document__c").set("v.value", false);
        }
    },
    
    onEntitySelectionChange : function(component, event, helper) {
        var cmpTarget = component.find('entityWrapper');
        var type = component.find("applyingType").get("v.value");

        if(type != "Entity"){

            component.set("v.hideFields", true);
        	helper.toggleEntityFields(component);
            $A.util.addClass(cmpTarget, 'slds-hide');

        }
        else{
           $A.util.removeClass(cmpTarget, 'slds-hide');
            component.set("v.hideFields", false);
            helper.toggleEntityFields(component);
        }
        
        component.set("v.entitySelections", type);

        var a = component.get('c.onTypeChange');
        $A.enqueueAction(a);
    },
    
	onTypeChange : function(component, event, helper) {
        var aType = component.find("applyingType").get("v.value");
        var cmpTarget = component.find('entityInfoWrapper');
        var type = component.find('entityType').get("v.value");
        if(type != "To be formed" && (type != "" || type != null ) && (aType != "" && aType != null )){
            $A.util.removeClass(cmpTarget, 'slds-hide');
            component.set("v.hideFields", false);
        }
        helper.toggleEntityFields(component);
        
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

     onSubmit : function(component,event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields");


        if(helper.shouldClearFields(component,helper)){
            eventFields = helper.removeEntityTypeFieldsOnSubmit(component,helper,eventFields);
        }

        component.find("editForm").submit(eventFields);

    },

    onError : function(component,event, helper) {
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        scroll(0,80);
    },

     handleMouseOver: function(component,event, helper) {
        //event.getSource().getLocalId(); gets aura id
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