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
    var checklistItemsList = [];
    action.setParams({checkListId : ChecklistId});
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (response.getState() === 'SUCCESS') {
            var checkListItems = JSON.parse(response.getReturnValue());   
            for(var i = 0; i< checkListItems.length; i++){
                for(var j = 0; j<checkListItems[i].checklistItems.length; j++){
                    var tempCLI = {};
                    tempCLI.categoryIndex = i;
                    tempCLI.libraryIndex = j;
                    tempCLI.pipCI = checkListItems[i].checklistItems[j].pipCI;
                    checklistItemsList.push(tempCLI);
                    checkListItems[i].checklistItems[j].categoryIndex = i;
                    checkListItems[i].checklistItems[j].libraryIndex = j;
                }
            }      
            component.set("v.checklistItems",checkListItems );
            component.set("v.flatObjects",checklistItemsList);
            component.set("v.filteredData",checkListItems );              
        } else {
            var errors = response.getError();
            console.log('Setting false value to spinner in getPIPLibraryItems2.');
        }
    });
    $A.enqueueAction(action);	
    }
})