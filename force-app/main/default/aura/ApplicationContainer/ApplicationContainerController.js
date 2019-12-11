({
	init : function(component, event, helper) {
        if(component.get("v.applicationSet") != true){
			component.set("v.step", 1);
            component.set("v.applicationSet", true); 
        }
	},

	onPageLoad:function(component, event, helper){
		helper.getInitialData(component,helper);

	},

})