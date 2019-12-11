({

    initData: function(component,event, helper){
        helper.populateDate(component,helper);
    },

	handleSubmit : function(component, event, helper) {
		helper.submitEditForm(component,helper);
	},

	onSubmitSuccess: function(component, event, helper) {
		helper.showToast(component,helper,'success', '20000', 'Your application was successfully submitted. Thank you for applying to Choice Hotels!');

		helper.refreshView(component,helper);
		component.find("overlayLib").notifyClose();
	},

	onError : function(component,event, helper) {
        helper.showToast(component,helper,'other','5000', 'Please review the errors on the page.');
        scroll(0,80);
    },

    onLoad: function(component,event, helper) {
        component.find("section").set("v.value", "Confirmation");
	},


	
	
})