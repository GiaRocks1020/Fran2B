({
    init: function (cmp, event, helper) {
        var createDeal = cmp.get('v.createDeal');
        if(typeof(createDeal) == "undefined"){
            cmp.set('v.createDeal',true);         
        }
        //fetches fields for Properties on initiation/load
        if(cmp.get('v.lead') != null){
            helper.fetchPropertyFields(cmp);
    	}
    },
    
    checkSelection : function(component, event, helper) {
        var selectId = component.get('v.selectedId');
        if(selectId != "new"){
            component.set('v.isNewProperty', false);
        }
    },
    
    setNewProperty : function(component, event, helper) {
		helper.setNewPropertyFields(component);
    }
})