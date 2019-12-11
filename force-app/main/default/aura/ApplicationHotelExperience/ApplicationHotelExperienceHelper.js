({

	
    
	showToast:function(component,helper,errorType,duration, message){
        var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type": errorType,
                "duration":duration,
                "message": message
            });
        toastEvent.fire();
    },

})