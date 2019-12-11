({
    init: function (cmp, event, helper) {
        //fetches fields for Contacts on initiation/load
        if(cmp.get('v.lead') != null){
            helper.fetchContactFields(cmp);
    	}
    },
    
    checkSelection : function(component, event, helper) {
        var selectId = component.get('v.selectedId');
        if(selectId != "new"){
            component.set('v.isNewContact', false);
        }
    },
    
    setNewContact : function(component, event, helper) {
		helper.setNewContactFields(component);
    },
          
    handleShowModal: function(component, evt, helper) {   
       var cmpTarget = component.find('Modalbox');
       var cmpBack = component.find('Modalbackdrop');
       $A.util.addClass(cmpTarget, 'slds-fade-in-open');
       $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
	closeModal : function(component, evt, helper){    
       var cmpTarget = component.find('Modalbox');
       var cmpBack = component.find('Modalbackdrop');
       $A.util.removeClass(cmpBack,'slds-backdrop--open');
       $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
   },
    
    handleShowAccounts: function(cmp, evt, helper) {
        cmp.set('v.showAccounts', true);
        console.log(cmp.get('v.showAccounts'));
    }
})