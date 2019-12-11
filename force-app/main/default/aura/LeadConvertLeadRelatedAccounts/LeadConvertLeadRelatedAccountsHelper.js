({   
	fetchAccounts : function(cmp) {
		var action = cmp.get('c.getAccountsRelatedToLead');
        var lead = cmp.get('v.lead');
        action.setParams({l : lead});
        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            console.log(response.getReturnValue())
            if (state === "SUCCESS") {
                var accounts = JSON.parse(response.getReturnValue());
                cmp.set('v.accountWrappers', accounts);
                cmp.set('v.dataLoaded', true);
                this.checkNewAccountIfNoAccounts(cmp);
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
                cmp.set('v.dataLoaded', true);
            }
        }));
        $A.enqueueAction(action);
	},
    
    fetchAccountFields : function(cmp) {
    	var action = cmp.get('c.getLeadConvertAccountFields');
        action.setCallback(this, function (response){
           var state = response.getState();
            if(state === "SUCCESS"){
             	var fields = response.getReturnValue();
                console.log(response.getReturnValue());
                //loop over and set columns correctly
                var columns = [];
                for(var i = 0; i < fields.length; i++){
                    console.log(fields[i].Field_API_Name__c);
                    console.log(fields[i].Label);
                    columns.push({label: fields[i].Label, fieldName: fields[i].Field_API_Name__c,});
                }
                
                console.log(columns);
                cmp.set('v.accountColumns',columns);
                this.fetchAccounts(cmp);
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
	},
    
    checkNewAccountIfNoAccounts : function(cmp){
        var accounts = cmp.get('v.accountWrappers');
        var contactAccounts = cmp.get('v.contactAccounts');
        if(accounts.length == 0 && contactAccounts.length == 0){
            this.setNewAccountAttributes(cmp);
        }
    },
    
    setNewAccountAttributes: function (cmp) {
        cmp.set('v.isNewAccount', true);
        cmp.set('v.selectedId', "new");
        cmp.set('v.selectedAccount', null);

    }
})