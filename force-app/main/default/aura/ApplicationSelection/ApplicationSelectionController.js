({
	init : function(component, event, helper) {
	},
    
    handleClick : function(component, event, helper) {
        var selectedApp = event.getSource().get("v.value");
        component.set("v.appRecord", selectedApp);
	}
})