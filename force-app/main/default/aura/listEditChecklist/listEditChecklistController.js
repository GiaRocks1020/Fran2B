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
    * @description Function that handles the Save function 
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
    * @description Function for auto save on the search. 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    setValuetoComponent: function(component, event, helper){
        var filterRecords = [];
        var checkListItems = [];
        filterRecords = component.get("v.filteredData");
        checkListItems = component.get("v.checkListItems");
        for(var i = 0; i< filterRecords.size; i++){
            for(var j = 0; j<filterRecords[i].checkListItems[i].size; j++){
                checkListItems[filterRecords[i].checklistItems[j].categoryIndex].checklistItems[checkListItems[i].checklistItems[j].libraryIndex].pipCI = filterRecords[i].checkListItems[i].pipCI;
            }
        }
        component.set("v.checkListItems",checkListItems);
    },
    /**
    * @description Function that handles the Table Filtering
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    filterLibraryItems: function(component, helper){
        var term = component.get("v.LibraryFilter") != null?component.get("v.LibraryFilter"):"";
        if(term.length>0)
            term = term.trim();
        if(term.length>0){
        var data = component.get("v.flatObjects");
        var filterData = [];
            filterData = data.filter(function (el) {
            var isQuestionMatch = (el.pipCI.Question__c != null ) ? el.pipCI.Question__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isCategoryMatch = (el.pipCI.Category__c != null ) ? el.pipCI.Category__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isMatch = false;
            isMatch = (isQuestionMatch || isCategoryMatch);
            return isMatch;
            });     
        try{        
        var filteredChecklist = [];
        filterData.sort(function(a, b) {
            if (a.pipCI.Category__c < b.pipCI.Category__c) {
              return -1;
            }
            if (a.pipCI.Category__c > b.pipCI.Category__c) {
              return 1;
            }
            if (a.pipCI.Category__c == b.pipCI.Category__c) {
                if (a.pipCI.Order__c > b.pipCI.Order__c) {
                    return -1;
                  }
                  if (a.pipCI.Order__c < b.pipCI.Order__c) {
                    return 1;
                  }
            }
        });
        var tempCat = filterData[0].Category__c;
        var tempObjList = {};
        tempObjList.checklistItems = [];
     
        for(var i=0;i<filterData.length;i++){
            if(tempCat != filterData[i].pipCI.Category__c){
                if(tempObjList.checklistItems.length > 0)
                    filteredChecklist.push(tempObjList);
                tempCat = filterData[i].pipCI.Category__c;
                tempObjList = {};
                tempObjList.checklistItems = [];
            }
            var tempPIP = {};  
            tempPIP.pipCI = filterData[i].pipCI;
            tempPIP.categoryIndex =  filterData[i].categoryIndex;
            tempPIP.libraryIndex = filterData[i].libraryIndex;
            tempObjList.checklistItems.push(tempPIP);
            tempObjList.checklistType = tempCat;
        }
        if(tempObjList.checklistItems != null)
            if(tempObjList.checklistItems.length > 0)
                filteredChecklist.push(tempObjList);

        }

         catch(error){
            console.log(error.message);
        }
        component.set("v.filteredData", filteredChecklist);
    }
    if(term.length==0){
        var data = component.get("v.checklistItems");
        component.set("v.filteredData", data);
    }
    component.set('v.showspinner',false);
    },
    /**
    * @description Function that handles closing of the Modal. 
    *
    * @author Madan Morusu
    * @date 2019-09-27
    */   
    closeModal : function(component,helper) {
        $A.get("e.force:closeQuickAction").fire()	
    }
})