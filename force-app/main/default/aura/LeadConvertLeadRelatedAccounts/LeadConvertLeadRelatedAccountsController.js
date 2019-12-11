({
    init: function (cmp, event, helper) {
        helper.fetchAccountFields(cmp);
    },
    
    checkSelection : function(component, event, helper) {
        var selectId = component.get('v.selectedId');
        if(selectId != "new"){
            component.set('v.isNewAccount', false);
        }
    },
    
    setNewAccount: function (component, event, helper) {
		helper.setNewAccountAttributes(component, event, helper);
    }
})