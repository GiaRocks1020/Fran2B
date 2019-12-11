({
	init : function(component, event, helper) {
		helper.createDisplayData(component);
        
        var selectedContact = component.get('v.selectedContact');   
        var contactId = component.get('v.contact.Id');
		//if the contact has already been selected, reselect if user navigates back
        if(typeof(selectedContact) !="undefined" && selectedContact != null){
           	if(selectedContact.Id === contactId){
            	component.set('v.isSelected', true);
        	}  
        }      
	},
    
    checkSelection : function(component, event, helper) {
        var selectedId = component.get('v.selectedId');
        var contactId = component.get('v.contact.Id');
		//if the button id and the contact id don't match set to false
        if(selectedId != contactId){
            component.set('v.isSelected', false);
        }
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
    
   isClicked: function(component, evt, helper) {
       component.set('v.selectedId', component.get('v.contact.Id'));
       component.set('v.selectedContact', component.get('v.contact'));
    }
})