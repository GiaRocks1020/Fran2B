({   
	fetchAccounts : function(cmp) {
		var action = cmp.get('c.getAccountsFromContactId');
        var contact = cmp.get('v.contact');
        if(contact != null){
            action.setParams({contactId : contact.Id});
            action.setCallback(this, $A.getCallback(function (response){
                var state = response.getState();
                //console.log(response.getReturnValue())
                if (state === "SUCCESS") {
                    cmp.set('v.accounts', response.getReturnValue());
                    cmp.set('v.dataLoaded', true);
                } else if(state === "ERROR"){
                    var errors = response.getError();
                    console.error(errors);
                    cmp.set('v.dataLoaded', true);
                }
            }));
            $A.enqueueAction(action);            
        }
        else {
            cmp.set('v.dataLoaded', true);
        }
	},
    
    fetchAccountFields : function(cmp) {
    	var action = cmp.get('c.getLeadConvertAccountFields');
        action.setCallback(this, function (response){
           var state = response.getState();
            if(state === "SUCCESS"){
             	var fields = response.getReturnValue();
                //loop over and set columns correctly
                var columns = [];
                for(var i = 0; i < fields.length; i++){
                    columns.push({label: fields[i].Label, fieldName: fields[i].Field_API_Name__c,});
                }
                
                //console.log(columns);
                cmp.set('v.accountColumns',columns);
                //once columns are set, retrieve account data
                this.fetchAccounts(cmp);
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
                cmp.set('v.dataLoaded', true);
            }
        });
        $A.enqueueAction(action);
	}
})