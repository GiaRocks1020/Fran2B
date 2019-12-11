({

    onInit: function(component, event, helper) {
        helper.removeSpinner(component,helper);

        if(component.get("v.newApplication.Application_Start_Date__c") ==null) {
            helper.setFirstTimeData(component,helper);
        }else{
            helper.fetchPrivateFiles(component,helper);
        }

        component.set("v.showDualBrand", component.find("isDualBrand").get("v.value"));
    },


    showPropertyCode : function(component, event, helper) {
        var type = component.find("appType").get("v.value");

        if(type == "Relicensing" || type == "Repositioning" || type == "Renewal") {
            component.set("v.showPropCode", true);
        }else{
            component.set("v.showPropCode", false); 
        }
    },
	
    onError : function(component,event, helper) {
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        scroll(0,80);
    },
    
    onSuccess : function(component,event, helper) {
        console.log("save success");
        helper.incrementStep(component,helper);
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
    
    resetState: function(component,event, helper) {
        var currentVal = component.get("v.toggleInput");
        component.set("v.toggleInput",!currentVal);
        component.find("state1").set("v.value", null);
        component.find("state2").set("v.value", null);
    },
})