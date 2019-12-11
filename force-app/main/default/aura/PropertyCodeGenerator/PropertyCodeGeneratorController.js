({
	init : function(component, event, helper) {
		helper.getEnvelope(component,helper);
	},

	generateCodeClick:function(component, event, helper){
		helper.showOrHideSpinner(component,true);
		helper.getNextCode(component,helper);
		
	},

	onAcceptClick:function(component, event, helper){
		helper.showOrHideSpinner(component,true);
		if(component.get("v.manualChange")){
			helper.saveManualCode(component,helper);
		}else{
			helper.saveAutoCode(component,helper);
		
				}

	},

	onDisplayCodeChange:function(component, event, helper){
		helper.checkIfManual(component,helper);
		if(component.get("v.manualChange")){
			helper.checkIfCodeTaken(component,helper);
			if(!helper.validate(component,helper)){
				helper.displayError(component,$A.get("$Label.c.Invalid_Code_Format"));
				helper.toggleButton(component,"acceptCode", "true");
			}
			else{
				helper.toggleButton(component,"acceptCode", "false");
			}
			
		}
	},


})