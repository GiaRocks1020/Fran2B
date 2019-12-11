({
	init : function(component, event, helper) {
    	helper.createDisplayData(component);
    },
    
   isClicked: function(component, evt, helper) {
       component.set('v.selectedId', component.get('v.account.Id')+component.get('v.type'));
       component.set('v.selectedAccount', component.get('v.account'));
    },
    
    checkSelection : function(component, event, helper) {
        var selectedId = component.get('v.selectedId');
        var accountId = component.get('v.account.Id');
        var type = component.get('v.type');
		//if the button id and the account id don't match set to false
        if(selectedId != accountId + type){
            component.set('v.isSelected', false);
        }
    },
})