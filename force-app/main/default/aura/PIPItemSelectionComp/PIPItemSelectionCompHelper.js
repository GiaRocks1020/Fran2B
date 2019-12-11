({
    /**
    * @description function to query PIPLibraryItems 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
	getPIPLibraryItems : function(component,helper) {
        var action = component.get("c.getLibraryItemWrapperList");
        action.setParams({pipId : component.get('v.recordId'),
                          sortField : "Category__c, PI_Short_Name__c",
                          sortDirection : "DESC"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            try{
            if (response.getState() === 'SUCCESS') {
                var libraryItems = JSON.parse(response.getReturnValue());               
            	component.set("v.dataObjects",libraryItems );
                var categoryfilterData = [];
				categoryfilterData = libraryItems.filter(function (el) {
                return el.pipLibraryItem.Program__c == "PIP" ;
            	});                
                component.set("v.filteredDataObjects",categoryfilterData );
                component.set("v.SelectedCategory","PIP");
                var s = JSON.stringify(libraryItems[0]);
                console.log('Setting false value to spinner in getPIPLibraryItems1.'+s);

            } else {
                var errors = JSON.stringify(response.getError());
                console.log('Setting false value to spinner in getPIPLibraryItems2.'+errors);

            }}
            catch(error){
                console.log(error.message);
            }
            component.set("v.showspinner",false);
        });
        $A.enqueueAction(action);		
    }, 
    /**
    * @description Function to filte PIPLibraryItems based on the text entered in the search box and Category and SubCategory Filters.. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    filterLibraryItems: function(component, helper){
        var term = component.get("v.LibraryFilter") != null?component.get("v.LibraryFilter"):"";
        var category = component.get("v.SelectedCategory");
        var subCategory = component.get("v.SelectedSubCategory");
        var checkCategoryFilter = (typeof category) == "string"?(category != "Select One" ? true:false):false;
        var checkSubCategoryFilter = (typeof subCategory) == "string"?(subCategory != "Select One" ? true:false):false;        
        if(term.length>1 || checkCategoryFilter || checkSubCategoryFilter){
        var data = component.get("v.dataObjects");
        var filterData = [];
        var categoryfilterData = [];
        if(term.length>1){
            filterData = data.filter(function (el) {
            var isCategoryMatch = ( typeof category == "string" && category != "Select One") ? el.pipLibraryItem.Program__c == category : true ;
            var isSubCategoryMatch = ( typeof subCategory == "string" && subCategory != "Select One") ? el.pipLibraryItem.Category__c == subCategory : true ;
            var isNameMatch = (el.pipLibraryItem.PI_Short_Name__c != null ) ? el.pipLibraryItem.PI_Short_Name__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isCatMatch = (el.pipLibraryItem.Program__c != null ) ? el.pipLibraryItem.Program__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isSubCatMatch = (el.pipLibraryItem.Category__c != null ) ? el.pipLibraryItem.Category__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isDescMatch = (el.pipLibraryItem.PI_Description__c != null ) ? el.pipLibraryItem.PI_Description__c.toLowerCase().indexOf(term.toLowerCase())>-1:false;
            var isMatch = false;
            isMatch = (isCategoryMatch && isSubCategoryMatch && (isNameMatch || isCatMatch || isSubCatMatch || isDescMatch));
            return isMatch;
            });     
        }
        if(term.length<2){
            categoryfilterData = data.filter(function (el) {
                return ( typeof category == "string" && category != "Select One") ? el.pipLibraryItem.Program__c == category : 1 ;
            });
            filterData = categoryfilterData.filter(function (el) {
                return ( typeof category == "string" && subCategory != "Select One") ? el.pipLibraryItem.Category__c == subCategory : 1 ;
            });
        }
        component.set("v.filteredDataObjects", filterData);
    }
    if(term.length==0 && !checkCategoryFilter && !checkSubCategoryFilter){
        var data = component.get("v.dataObjects");
        component.set("v.filteredDataObjects", data);
    }
    component.set('v.showspinner',false);
    },
    /**
    * @description Create PIP Line Items and redirect the user to PIP Record Page 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    createPIPItems: function(component,event,helper) {
        var pipitemSelectedList = component.get('v.SelectedData');
        if(pipitemSelectedList.length>0){
            var action = component.get("c.createPIPItems");
            var pipId = component.get('v.recordId');
            var libraryItemsList = JSON.stringify(pipitemSelectedList);
            action.setParams({"pipId" : pipId,
                                "pipLibraryItems" : libraryItemsList
                              });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var navService = component.find("navService");
                if (response.getState() === 'SUCCESS') {
                var pageReference =   {    
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": pipId,
                        "objectApiName": "TaskRay__Project__c",
                        "actionName": "view"
                    }
                    };
                    event.preventDefault();
                    navService.navigate(pageReference);
                } else {

                    var errors = response.getError();
                    component.set('v.showspinner',false);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            alert('Select at least one Library Item');
            component.set('v.showspinner',false);
        }
    },
    
    /**
    * @description Function to load the Sub category Pick list values when Category picklist value is changed.  
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */    
    pickListValueChanged: function(component, helper, event){
        var category = component.get("v.SelectedCategory");
        var picklistMap = component.get("v.subCategoryMap");
        var subCategoryPicklist = [];

        for(var i = 0; i<picklistMap.length; i++){
            if(picklistMap[i].controllingPicklist == category ){
                if(picklistMap[i].dependentPickList != null 
                    && picklistMap[i].dependentPickList.length > 0){
                     for(var j = 0; j<picklistMap[i].dependentPickList.length;j++){
                         subCategoryPicklist.push(picklistMap[i].dependentPickList[j]);
                     }
                    break;
           }
        }
    }
        if(subCategoryPicklist.length>0){
            subCategoryPicklist.push('Select One');
            component.set("v.showSubCategory",true);
            component.set("v.SelectedSubCategory","Select One");
        }
        component.set("v.subCategoryList",subCategoryPicklist);
    },

    /**
    * @description Function to load the Category and Sub category Pick list values.  
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */    
    getsubCategoryPicklist: function(component, helper, event){
        var action = component.get("c.getSubCategoryPickList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() === 'SUCCESS') {
                var dependentpicklist = JSON.parse(response.getReturnValue());               
                component.set("v.subCategoryMap",dependentpicklist );    
                var categories = [];
                for(var i = 0; i<dependentpicklist.length;i++){
                    categories.push(dependentpicklist[i].controllingPicklist);
                   if(dependentpicklist[i].dependentPickList != null && dependentpicklist[i].dependentPickList.length >0 ){
                }
                }
                component.get("v.SelectedCategory","PIP");
                component.set("v.categoryList",categories);      
                
            } else {
                var errors = response.getError();
                console.log('+++'+errors);
            }
        });
        $A.enqueueAction(action);
    }   
})