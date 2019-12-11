({
	createDisplayData : function(cmp) {
        //gets the data based on the api name
		var property = cmp.get('v.property');
        var apiNames = cmp.get('v.apiNames');
        var percentages = cmp.get('v.percentages');
        var displayData = [];
        for(var i = 0; i < apiNames.length; i++){
            displayData.push(apiNames[i].fieldName);
        }
        cmp.set('v.displayData', displayData);
	}
})