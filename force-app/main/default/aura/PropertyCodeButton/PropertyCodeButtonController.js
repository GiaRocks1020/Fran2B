({
	init: function(component, event, helper) {
		helper.getData(component,helper)
	},

	onGenerateClick : function(component, event, helper) {
		helper.openModal(component);
	},

	onCancelClick: function(component, event, helper) {
		helper.closeModal(component);
	},

	handleCloseModal:function(component, event, helper) {
      helper.closeModal(component);
      component.set("v.toShow", false);
    },
})