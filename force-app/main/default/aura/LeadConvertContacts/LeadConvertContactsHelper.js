({
	fetchContacts : function(cmp) {
		var action = cmp.get('c.getContacts');
        action.setParams({l : cmp.get('v.lead')});
        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            //if success set the contacts
            if (state === "SUCCESS") {
                var contacts = JSON.parse(response.getReturnValue());
				//if wrapper is empty then set to new contact                
                if(contacts.length == 0){
                    this.setNewContactFields(cmp);
                }
  
                cmp.set('v.contactWrappers', contacts);
                cmp.set('v.dataLoaded', true);
            } else if(state === "ERROR"){
                var errors = response.getError();
                cmp.set('v.dataLoaded', true);
                console.error(errors);
                this.setNewContactFields(cmp);
            }
        }));
        $A.enqueueAction(action);
	},
    
    fetchContactFields : function(cmp) {
    	var action = cmp.get('c.getLeadConvertContactFields');
        action.setCallback(this, function (response){
           var state = response.getState();
            //If success add the required fields to the column
            if(state === "SUCCESS"){
             	var fields = response.getReturnValue();
                var columns = [];

                for(var i = 0; i < fields.length; i++){
                    columns.push({label: fields[i].Label, fieldName: fields[i].Field_API_Name__c,});
                }
                cmp.set('v.contactColumns',columns);
                //once columns are set, retrieve contact data
                this.fetchContacts(cmp);
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
	},
    
	setNewContactFields : function(cmp) {
        cmp.set('v.isNewContact', true);
        cmp.set('v.selectedId', "new");
        cmp.set('v.contact', null);
    }
})