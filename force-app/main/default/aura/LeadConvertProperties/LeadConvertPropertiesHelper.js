({
	fetchPropertyFields : function(cmp) {
		var action = cmp.get('c.getLeadConvertPropertyFields');
        action.setCallback(this, function (response){
           var state = response.getState();
            //If success add the required fields to the column
            if(state === "SUCCESS"){
             	var fields = response.getReturnValue();
                var columns = [];

                for(var i = 0; i < fields.length; i++){
                    columns.push({label: fields[i].Label, fieldName: fields[i].Field_API_Name__c,});
                }
                cmp.set('v.propertyColumns',columns);
                //once columns are set, retrieve property data
                this.fetchProperties(cmp);
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);		
	},
    
    fetchProperties : function(cmp){
        var action = cmp.get('c.getProperties');
		action.setParams({l : cmp.get('v.lead')});
        action.setCallback(this, $A.getCallback(function (response){
            var state = response.getState();
            //if success set the property
            if (state === "SUCCESS") {
                var properties = JSON.parse(response.getReturnValue());
				//if wrapper is empty then set to new property               
                if(properties.length == 0){
                    this.setNewPropertyFields(cmp);
                }
  
                cmp.set('v.propertyWrappers', properties);
                cmp.set('v.dataLoaded', true);
            } else if(state === "ERROR"){
                var errors = response.getError();
                cmp.set('v.dataLoaded', true);
                console.error(errors);
                this.setNewPropertyFields(cmp);
                cmp.set('v.dataLoaded', true);
            }
        }));
        $A.enqueueAction(action);	        
    },
    
    setNewPropertyFields : function(cmp) {
        cmp.set('v.isNewProperty', true);
        cmp.set('v.selectedId', "new");
        cmp.set('v.property', null);
    }
})