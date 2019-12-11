({
	init : function(component, event, helper) {
		helper.retrieveFileNames(component);

		
	},
	onSuccess: function(component, event, helper) {
		//var error  = event._params.message;
		debugger;
	},
	onError: function(component, event, helper) {
		var error  = event._params.message;
		debugger;
	},

	onDeleteClick: function(component, event, helper) {
		var curIndex = event.currentTarget.dataset.index;
		component.set('v.curIndex', curIndex);
		helper.openModal(component,'Modalbox');

	},

	handleCancelDeletion: function(component, event, helper) {
		helper.closeModal(component,'Modalbox');
	},

	handleDeleteConfirmation: function(component, event, helper) {
		
		var documents = component.get("v.documents");
        var curIndex = component.get("v.curIndex");
        var idToDelete = documents[curIndex].contentDocumentId;
        var parentId = documents[curIndex].link.LinkedEntityId;
		helper.deleteFile(component,helper,idToDelete,parentId);
		
	},
})