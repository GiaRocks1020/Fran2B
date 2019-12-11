({
    init : function(component, event, helper) {
        try{
            helper.getCheckListItems(component,event,helper);
        }
        catch(error){
            console.log('ERROR'+error.message);
        }
    },
    /**
    * @description Function for auto save on the search. 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    saveAndCancel : function(component, event, helper){
        var action = component.get("c.saveChecklistItems");
        var wrapperList = component.get("v.checklistItems");
            action.setParams({WrapperString : JSON.stringify(wrapperList)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getState() === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": "dismissible",
                        "duration":"2000ms",
                        "type":"success",
                        "title": "Success!",
                        "message": "The record has been updated successfully."
                    });
                    helper.getCheckListItems(component,event,helper);
                    toastEvent.fire();            
                } else {
                    var errors = response.getError();
                    var errorString = errors[0].message;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": "dismissible",
                        "duration":"2000ms",
                        "type":"error",
                        "title": "Error!",
                        "message": errorString
                    });
                    toastEvent.fire();
                    console.log('Setting false value to spinner in getPIPLibraryItems2.'+errors);
                }
            });
            $A.enqueueAction(action);
    },
    /**
    * @description Function for toggle the edit mode 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    toggleEdit : function(component, event, helper){
        var editMode = false;
        editMode = component.get("v.editMode");
        editMode = editMode==false?true:false;
        component.set("v.editMode",editMode);
    }
})