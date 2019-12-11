({
	createDisplayData : function(cmp) {
		var account = cmp.get('v.account');
        var apiNames = cmp.get('v.apiNames');
        var displayData = [];
        for(var i = 0; i < apiNames.length; i++){
            displayData.push(account[apiNames[i].fieldName]);
        }
        
        cmp.set('v.displayData', displayData);
	}
})