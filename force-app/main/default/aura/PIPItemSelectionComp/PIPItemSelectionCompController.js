({
    /**
    * @description Init Function
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    init : function(component, event, helper) {
        component.set('v.showspinner',true);
        component.set('v.LineItemCount',0);
        component.set('v.showFilters',0);
        component.set('v.hideFilters',1);
        helper.getPIPLibraryItems(component);
        helper.getsubCategoryPicklist(component, helper, event);
    },
    /**
    * @description Function called on Category/Sub Category value change. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    categoryChange : function(component, event, helper) {
        helper.filterLibraryItems(component,helper);
        helper.pickListValueChanged(component,helper,event);
    },
    /**
    * @description Function called to filter the table. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */    
    filterData : function(component, event, helper) {
        helper.filterLibraryItems(component,helper);
    },
    /**
    * @description Function called on the hit of cancel button to close the modal. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */    
    closeModal : function(component,helper) {
        $A.get("e.force:closeQuickAction").fire()	
    },
    /**
    * @description Function called on the hit of Create Line Items, this will create line items and redirect user to PIP Record Page. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    createPIPLineItems : function(component, event, helper) {
        component.set('v.showspinner',true);
        helper.createPIPItems(component, event, helper);
    },
    /**
    * @description Function that handles the PIP Item selection. 
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */    
    pipitemSelected : function(component,event,helper) {
    try{
       var eventId = event.currentTarget.id;
       var pipitemSelectedList = component.get('v.SelectedData');
       var data = component.get('v.dataObjects');
      
       if(pipitemSelectedList.length > 0 && pipitemSelectedList.indexOf(eventId)>-1){
            pipitemSelectedList.splice(pipitemSelectedList.indexOf(eventId),1);
            for(var i=0;i<data.length;i++){
                if(data[i].pipLibraryItem.Id == eventId)
                    data[i].isSelected = false;
            }
        }
      else{
        pipitemSelectedList.push(eventId);
            for(var i=0;i<data.length;i++){
                if(data[i].pipLibraryItem.Id == eventId){
                   data[i].isSelected = true;
                }
            }
       }
        component.set('v.SelectedData',pipitemSelectedList);
        component.set('v.LineItemCount',pipitemSelectedList.length);
        component.set('v.dataObjects',data); }
        catch(error){
            console.log('Error'+error.message);
        }
    },

    /**
    * @description Function to handle the show/reset filters.  
    *
    * @author Madan Morusu
    * @date 2019-09-10
    */
    toggleFilters: function(component, event, helper){
        var showFilters = false;
        showFilters = component.get("v.showFilters");
        component.set("v.showFilters",!showFilters);
        component.set("v.hideFilters",showFilters);
        component.set("v.SelectedSubCategory","Select One");
        helper.pickListValueChanged(component,helper,event);
        if(showFilters == true){
            component.set('v.showspinner',true);
            window.setTimeout($A.getCallback(function(){
                helper.filterLibraryItems(component,helper)
            }, 0));                    
        }else{
            component.set('v.showspinner',false);
        }
        


    }
})