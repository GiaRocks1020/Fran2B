({
	fireUploadEvent:function(component,helper){
		var uploadEvent = $A.get("e.c:ApplicationUpload");
		uploadEvent.setParam("section", component.get("v.section"));
        uploadEvent.fire();
	},
})