({
    /**
    * @description Helper Function that gets checklist items. 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    getCheckListItems : function(component, event, helper){
        var ChecklistId = component.get("v.recordId");
        var action = component.get("c.getCheckListItems");
        action.setParams({checkListId : ChecklistId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() === 'SUCCESS') {
                var checkListItems = JSON.parse(response.getReturnValue());   
                component.set("v.checklistItems",checkListItems );               
            } else {
                var errors = response.getError();
                console.log('Setting false value to spinner in getPIPLibraryItems2.');
            }
        });
        $A.enqueueAction(action);	
    }
})