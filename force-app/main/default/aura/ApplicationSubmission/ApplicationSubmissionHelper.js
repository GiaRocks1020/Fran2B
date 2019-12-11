({
	
	submitEditForm:function(component,helper){
        component.find("editForm").submit();
    },




     refreshView:function(component,helper){
         $A.get('e.force:refreshView').fire();
     },

     showToast:function(component,helper,errorType,duration,message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "duration":duration,
                "message": message
            });
        toastEvent.fire();
    },



    populateDate: function(component, helper){
        var today = new Date();
        var dd = today.getDate();
        var year = today.getFullYear();
        var month = today.getMonth() +1;
        var dateString = year+'-' + month + '-' + dd;

        component.find("Today_Date__c").set("v.value", dateString);
    }
})