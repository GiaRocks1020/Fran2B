({
	retrieveFileNames : function(component) {
		var action = component.get("c.getFileUploads");

		action.setParams({appId : component.get("v.appId")});

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
				component.set("v.documents", response.getReturnValue());
			} else {
                var errors = response.getError();
                
                helper.showToast(component,helper,'other', errors[0].message);
            }
        });
        $A.enqueueAction(action);
	},

    deleteFile: function(component,helper,idToDelete,parentId) {
        var action = component.get("c.handleDeletionProcess");
        var section = helper.findSectionBeingDeleted(component,idToDelete);

        action.setParams({
            "documentId" : idToDelete,
            "section" : section,
            "parentId" : parentId
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var envelope = JSON.parse(response.getReturnValue());
                var isUpdateNeeded = envelope.updateUI;
                component.set("v.applicantId", envelope.applicantId);

                helper.retrieveFileNames(component);
                helper.showToast(component,helper,'other', 'File was successfully deleted.');
                helper.closeModal(component,'Modalbox');

                if(isUpdateNeeded){
                    helper.updateFieldForEditForm(component,helper,section);
                    helper.fireDeleteEvent(component,helper,section);

                }
                
            } else {
                var error = response.getError();
                helper.showToast(component,helper,'other', error[0].message);
            }
        });
        $A.enqueueAction(action);
    },



    updateFieldForEditForm:function(component,helper,section){
        var eventFields = {};
        eventFields['Section__c'] = "";
        if(section =='Deed__c'){
            section = 'Upload_Deed__c';
        }
        eventFields[section] = false;

        if(section == 'Additional_Document__c'){
            return;
        }
        else if( section =='Owner_Resume__c' || section == 'Personal_Financial_Statement__c'){
            component.find("editFormApplicant").submit(eventFields);
        }
        else{

            component.find("editFormApplication").submit(eventFields);
        }
        
    },

    fireDeleteEvent:function(component,helper,section){
        var deleteEvent = $A.get("e.c:ApplicationFileDeleted");
        deleteEvent.setParams({"uploadLocation" : section});
        deleteEvent.fire();
    },

    showToast:function(component,helper,errorType,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "message": message
            });
        toastEvent.fire();
    },

    findSectionBeingDeleted:function(component, idToDelete){
        var documents = component.get("v.documents");
        for(var x = 0; x<documents.length; x++){
            if(documents[x].contentDocumentId == idToDelete){
                return documents[x].section;
            }
        }
        return '';

    },

    closeModal : function(component,modalName){    
        var cmpTarget = component.find(modalName);
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
    },

    openModal : function(component,modalName) {
        var cmpTarget = component.find(modalName);
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        

    },

 

})