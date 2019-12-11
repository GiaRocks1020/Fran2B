({
	init : function(component, event, helper) {
		helper.createDisplayData(component);
        
        var selectedProperty = component.get('v.selectedProperty');
        var propertyId = component.get('v.property.Id');
		//if the property has already been selected, reselect if user navigates back
        if(typeof(selectedProperty) !="undefined"){
            if(selectedProperty != null){
             	if(selectedProperty.Id === propertyId){
            		component.set('v.isSelected', true);
        		} 
            }
        }   
	},
    
    checkSelection : function(component, event, helper) {
        var selectedId = component.get('v.selectedId');
        var propertyId = component.get('v.property.Id');
		//if the button id and the property id don't match set to false
        if(selectedId != propertyId){
            component.set('v.isSelected', false);
        }
    },
    
   isClicked: function(component, evt, helper) {
       component.set('v.selectedId', component.get('v.property.Id'));
       component.set('v.selectedProperty', component.get('v.property'));
    }
})