({
	onSubmit : function(component, event, helper) {
		var appEvent = $A.get("e.c:ApplicationSubmit");
		appEvent.fire();
	},

	onCancel:function(component,event,helper){
		  component.find("overlayLib").notifyClose();
	}
})