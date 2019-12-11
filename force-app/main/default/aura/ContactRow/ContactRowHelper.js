({
	createDisplayData : function(cmp) {
        //gets the data based on the api name
		var contact = cmp.get('v.contact');
        var apiNames = cmp.get('v.apiNames');
        var percentages = cmp.get('v.percentages');
        var displayData = [];
        for(var i = 0; i < apiNames.length; i++){
            displayData.push(contact[apiNames[i].fieldName]);
        }
        
        //cmp.set('v.percent', percentages[contact.Id]);
        cmp.set('v.displayData', displayData);
	}
})