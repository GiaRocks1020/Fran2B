({
	init : function(component, event, helper) {
        var legalRep = component.get("v.legalRep");
        console.log(legalRep);
        console.log("init start");
        helper.fetchLegalRepInfo(component,helper);
        console.log("init end");
	},
    
    onLoad : function(component, event, helper) {
        console.log("onLoad start");
            var test = component.get("v.legalRep.Salutation__c");
        helper.removeSpinner(component,helper);
    },

    incrementStep : function(component) {
		scroll(0,0);
		var step = component.get('v.step');
        component.set('v.step', step + 1);
    },

    handleFileDeletion:function(component,event,helper){
        helper.deleteTest(component,helper);
    },
    
    decrementStep : function(component, event, helper) {
        var step = component.get('v.step');
        if(step > 1){
        	component.set('v.step', step - 1);           
        }
    },
    onError : function(component,event, helper) {
        var error = event.error;
        helper.showToast(component,helper,'other', 'Please review the errors on the page.');
        scroll(0,80);
    },
})